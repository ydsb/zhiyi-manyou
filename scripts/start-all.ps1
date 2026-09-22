# =============================================================================
#  ZhiYi Manyou - one-command launcher   [ASCII-only, see NOTE]
#
#  Starts all three services in the right order, waits for each to become
#  healthy, then prints the exact URL to hand to a roommate.
#
#  USAGE
#      powershell -ExecutionPolicy Bypass -File .\scripts\start-all.ps1
#      powershell -ExecutionPolicy Bypass -File .\scripts\start-all.ps1 -Status
#      powershell -ExecutionPolicy Bypass -File .\scripts\start-all.ps1 -Stop
#
#  PASSWORD
#      Read from $env:ZHIYI_DB_PASSWORD. Prompts once (hidden) if unset, so the
#      password never reaches the command line or a file.
#
#  WHY THIS EXISTS
#      Every service had to be started by hand in three terminals. The failure
#      mode of forgetting one is silent and confusing: with the NLP service down
#      the parse endpoint still returns HTTP 200 with ZERO matches and a hint
#      telling the user their wording was too vague. The site looks fine.
#      This script starts them in order, verifies each one, and refuses to
#      report success unless the whole chain actually answers.
#
#  NOTE: ASCII-only ON PURPOSE, comments included. Windows PowerShell 5.1 parses
#        .ps1 as GBK on Chinese Windows without a UTF-8 BOM, and a stray Chinese
#        string can shift the parser into bogus "Unexpected token" errors on
#        unrelated lines. Chinese output is built from [char] codes instead, and
#        shared LAN helpers live in scripts\lib\lan.ps1.
# =============================================================================

[CmdletBinding()]
param(
    [ValidateSet('start', 'stop', 'status')]
    [string]$Action = 'start',

    [switch]$Status,
    [switch]$Stop,

    [int]$FrontPort   = 5173,
    [int]$BackendPort = 8080,
    [int]$NlpPort     = 8901,

    [string]$DbName = 'zhiyi_manyou',
    [string]$DbUser = 'root',
    [string]$DbHost = 'localhost',
    [int]   $DbPort = 3306,

    # Skip the semantic service (the app degrades to keyword-only matching).
    [switch]$NoNlp,
    # Window style for the three service consoles.
    [ValidateSet('Normal', 'Minimized')]
    [string]$WindowStyle = 'Minimized'
)

$ErrorActionPreference = 'Continue'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

if ($Status) { $Action = 'status' }
if ($Stop)   { $Action = 'stop' }

$script:pass = 0
$script:fail = 0

# --- Chinese output without Chinese literals (see NOTE) ----------------------
function New-Cn {
    param([int[]]$Codes)
    $sb = New-Object System.Text.StringBuilder
    foreach ($c in $Codes) { [void]$sb.Append([char]$c) }
    return $sb.ToString()
}
$tTitle   = New-Cn @(30693, 39551, 183, 28459, 28216, 32, 183, 32, 19968, 38190, 21551, 21160)
$tOk      = New-Cn @(36890, 36807)
$tFail    = New-Cn @(22833, 36133)
$tWarn    = New-Cn @(35686, 21578)
$tUrl     = New-Cn @(23460, 21451, 35775, 38382, 22320, 22336)
$tAcct    = New-Cn @(27979, 35797, 36134, 21495)
$tSameWifi= New-Cn @(20854, 20182, 35774, 22791, 38656, 19982, 20320, 21516, 19968, 32, 87, 105, 70, 105, 32, 32593, 27573)
$tAllOk   = New-Cn @(20840, 37096, 26816, 26597, 36890, 36807, 65292, 21487, 20197, 25226, 22320, 22336, 21457, 32473, 23460, 21451, 20102)
$tStarted  = New-Cn @(24050, 21551, 21160)
$tStopped  = New-Cn @(24050, 20572, 27490)
$tNotRun   = New-Cn @(26410, 21551, 21160)

function Write-Head ([string]$m) {
    Write-Host ''
    Write-Host ('=' * 66) -ForegroundColor Cyan
    Write-Host "  $m" -ForegroundColor Cyan
    Write-Host ('=' * 66) -ForegroundColor Cyan
}
function Write-Ok   ([string]$m) { Write-Host "  [$tOk] $m" -ForegroundColor Green;  $script:pass++ }
function Write-Bad  ([string]$m) { Write-Host "  [$tFail] $m" -ForegroundColor Red;   $script:fail++ }
function Write-Note ([string]$m) { Write-Host "        $m" -ForegroundColor DarkGray }
function Write-WarnLine ([string]$m) { Write-Host "  [$tWarn] $m" -ForegroundColor Yellow }

# --- shared LAN helpers ------------------------------------------------------
$libPath = Join-Path $PSScriptRoot 'lib\lan.ps1'
if (-not (Test-Path -LiteralPath $libPath)) {
    Write-Host "[x] missing helper: $libPath" -ForegroundColor Red
    exit 1
}
. $libPath

# --- paths -------------------------------------------------------------------
$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path -LiteralPath (Join-Path $repoRoot 'backend'))) {
    # Allow running from inside scripts\ as well.
    $repoRoot = $PSScriptRoot
    if (-not (Test-Path -LiteralPath (Join-Path $repoRoot 'backend'))) {
        Write-Host "[x] cannot locate the repo root (no 'backend' folder above $PSScriptRoot)" -ForegroundColor Red
        exit 1
    }
}

$jarPath    = Join-Path $repoRoot 'backend\zy-server\target\zy-server.jar'
$nlpScript  = Join-Path $repoRoot 'nlp-service\serve.py'
$frontDir   = Join-Path $repoRoot 'frontend'
$frontDist  = Join-Path $frontDir 'dist\index.html'
$mysqlExe   = $null
foreach ($cand in @("$env:ZHIYI_MYSQL_HOME\bin\mysql.exe", 'G:\DEV\mysql\bin\mysql.exe')) {
    if ($cand -and (Test-Path -LiteralPath $cand)) { $mysqlExe = $cand; break }
}

# Window titles double as process handles: 'taskkill /T /FI "WINDOWTITLE eq X"'
# kills the whole tree, which is how -Stop cleans up java/node/python children.
$winBackend = 'zhiyi-backend'
$winNlp     = 'zhiyi-nlp'
$winFront   = 'zhiyi-frontend'

# Window title -> path of the file recording the PID of the tree we started.
# Populated by Start-ServiceWindow, consumed by Stop-ServiceTree.
$script:servicePidFiles = @{}

# =============================================================================
#  helpers
# =============================================================================

# Runs a command line in its own console window and returns the Process object.
#
# Before the real command, the window writes its own PID to a .pid file. That
# file is what makes -Stop reliable.
#
# WHY NOT just kill by WINDOWTITLE, or by "is the parent alive":
#   Both were tried and both failed on real runs.
#   * taskkill /FI "WINDOWTITLE eq ..." kills the cmd.exe that owns the window,
#     but the actual server (node/python/java) is a GRANDchild and can survive
#     as an orphan still holding its port.
#   * "the parent is still alive, so it is not ours" is simply wrong: npm runs
#     the vite binary through an intermediate cmd.exe, so the leftover node
#     process had a live parent while being unequivocally ours. That test left
#     port 5173 held and made the next start report a conflict for a service
#     this script had just claimed to stop.
#   Recording our own PID and using "taskkill /T" on it kills the whole tree,
#   and a .pid file also proves the process is ours -- so -Stop still never
#   touches a service somebody else started by hand.
function Start-ServiceWindow {
    param(
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true)][string[]]$CommandLines
    )

    $tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ("zhiyi-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null
    $cmdFile = Join-Path $tmpDir 'run.cmd'
    $pidFile = Join-Path $tmpDir 'run.pid'

    # `title` first so taskkill's window filter still works as a fallback.
    # The PID is recorded by the launcher itself after Start-Process returns --
    # cmd.exe has no built-in PID variable, so it cannot write its own.
    $body = @("title $Title", '@echo off') + $CommandLines
    [System.IO.File]::WriteAllLines($cmdFile, $body, (New-Object System.Text.ASCIIEncoding))

    $proc = Start-Process -FilePath 'cmd.exe' -ArgumentList @('/c', $cmdFile) `
        -WindowStyle $WindowStyle -PassThru

    # Start-Process gives us the cmd.exe PID; its child tree holds the servers.
    Set-Content -LiteralPath $pidFile -Value $proc.Id -Encoding Ascii -NoNewline
    $script:servicePidFiles[$Title] = $pidFile
    return $proc
}

# Locates the PID file a previous start wrote for $Title.
#
# -Stop normally runs as a SEPARATE process from -Start, so the in-memory map is
# empty and the records must be recovered from disk. The temp folders are named
# with random GUIDs, but each holds the run.cmd we generated, whose first line is
# "title <name>" -- so the title is recoverable without any hidden state file.
function Find-ServicePidFile {
    param([Parameter(Mandatory = $true)][string]$Title)

    if ($script:servicePidFiles.ContainsKey($Title)) { return $script:servicePidFiles[$Title] }

    $dirs = @(Get-ChildItem -LiteralPath ([System.IO.Path]::GetTempPath()) -Directory -Filter 'zhiyi-*' -ErrorAction SilentlyContinue |
              Sort-Object LastWriteTime -Descending)
    foreach ($d in $dirs) {
        $cmdFile = Join-Path $d.FullName 'run.cmd'
        $pidFile = Join-Path $d.FullName 'run.pid'
        if (-not (Test-Path -LiteralPath $cmdFile)) { continue }
        if (-not (Test-Path -LiteralPath $pidFile)) { continue }
        try {
            $first = (Get-Content -LiteralPath $cmdFile -TotalCount 1)
            if ($first -match ('^title\s+' + [regex]::Escape($Title) + '\s*$')) { return $pidFile }
        } catch { }
    }
    return $null
}

# Kills the process tree rooted at the PID recorded for $Title, then removes the
# record. Returns $true when a tree was actually terminated.
function Stop-ServiceTree {
    param([Parameter(Mandatory = $true)][string]$Title)

    $pidFile = Find-ServicePidFile -Title $Title
    if (-not $pidFile) {
        # No record at all (e.g. started by hand): fall back to the window title.
        return (Stop-ByWindowTitle -Title $Title)
    }

    $rootPid = 0
    try { $rootPid = [int]((Get-Content -LiteralPath $pidFile -Raw).Trim()) } catch { $rootPid = 0 }
    if ($rootPid -le 0) { return (Stop-ByWindowTitle -Title $Title) }

    # /T walks the whole tree, which is what actually frees the ports: the
    # server is a grandchild of this cmd.exe.
    $null = & taskkill.exe /F /T /PID $rootPid 2>&1
    $killed = ($LASTEXITCODE -eq 0)
    if (-not $killed) { $killed = Stop-ByWindowTitle -Title $Title }
    Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue
    return $killed
}

# Polls a URL until it answers or the deadline passes. Returns $true on success.
function Wait-Http {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [int]$TimeoutSec = 90,
        [string]$Label = ''
    )
    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    $dots = 0
    while ((Get-Date) -lt $deadline) {
        if (Test-HttpOk -Url $Url -TimeoutSec 4) {
            if ($dots -gt 0) { Write-Host '' }
            return $true
        }
        Write-Host '.' -NoNewline
        $dots++
        Start-Sleep -Milliseconds 1200
    }
    if ($dots -gt 0) { Write-Host '' }
    return $false
}

function Stop-ByWindowTitle {
    param([Parameter(Mandatory = $true)][string]$Title)
    $out = & taskkill.exe /F /T /FI "WINDOWTITLE eq $Title" 2>&1
    # taskkill exits 128 when the filter simply matched nothing; that is not an
    # error worth reporting as a failure.
    return ($LASTEXITCODE -eq 0)
}

# =============================================================================
#  ACTION: status
# =============================================================================
function Invoke-Status {
    Write-Head ($tTitle + '  /  status')
    $ipInfo = Get-LanIPv4

    $rows = @(
        @{ Name = 'NLP 8901';     Port = $NlpPort;     Url = "http://127.0.0.1:$NlpPort/health" }
        @{ Name = 'Backend 8080'; Port = $BackendPort; Url = "http://127.0.0.1:$BackendPort/api/health" }
        @{ Name = 'Frontend 5173';Port = $FrontPort;   Url = "http://127.0.0.1:$FrontPort/" }
    )
    foreach ($r in $rows) {
        $listen = Test-PortListening -Port $r.Port
        $http   = if ($listen) { Test-HttpOk -Url $r.Url -TimeoutSec 5 } else { $false }
        $binds  = @(Get-PortBindAddresses -Port $r.Port)
        $state  = if ($http) { $tStarted } elseif ($listen) { 'listening, no HTTP' } else { $tNotRun }
        $color  = if ($http) { 'Green' } elseif ($listen) { 'Yellow' } else { 'DarkGray' }
        Write-Host ("  {0,-16} {1,-22} {2}" -f $r.Name, $state, ($(if ($binds.Count) { $binds -join ' | ' } else { '-' }))) -ForegroundColor $color
    }

    if ($ipInfo.Ip) {
        Write-Host ''
        Write-Host ("  $tUrl : http://$($ipInfo.Ip):$FrontPort/") -ForegroundColor Cyan
    }
    Write-Host ''
    exit 0
}

# =============================================================================
#  ACTION: stop
# =============================================================================
function Invoke-Stop {
    Write-Head ($tTitle + '  /  stop')
    foreach ($t in @($winFront, $winBackend, $winNlp)) {
        if (Stop-ServiceTree -Title $t) {
            Write-Ok "$t  $tStopped"
        } else {
            Write-Note "$t  $tNotRun"
        }
    }

    # window/PID killing is best-effort; confirm against the actual ports and
    # report anything still holding on, rather than assuming success
    Start-Sleep -Seconds 2
    $leftover = @()
    foreach ($p in @($FrontPort, $BackendPort, $NlpPort)) {
        $owner = Get-ListeningPid -Port $p
        if (-not $owner) { Write-Note "port $p free"; continue }

        $procName = 'unknown'
        try { $procName = (Get-Process -Id $owner -ErrorAction Stop).ProcessName } catch { }

        # We reached here despite killing our own trees, so this process is not
        # one we started -- leave it alone and say so. -Stop must never kill a
        # server the user launched by hand in another terminal.
        $leftover += $owner
        Write-WarnLine "port $p still held by PID $owner ($procName) - not ours, leaving it alone"
        Write-Note "stop it manually if it is a leftover: Stop-Process -Id $owner -Force"
    }
    Write-Host ''
    if ($leftover.Count -eq 0) { Write-Ok 'all service ports are free' }
    exit 0
}

# =============================================================================
#  ACTION: start
# =============================================================================
function Invoke-Start {
    Write-Head $tTitle

    # ---------------- 0. preconditions --------------------------------------
    Write-Host ''
    Write-Host '  [0/4] preconditions' -ForegroundColor Cyan

    if (-not $env:ZHIYI_DB_PASSWORD) {
        $sec = Read-Host -Prompt '  MySQL password' -AsSecureString
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
        try   { $env:ZHIYI_DB_PASSWORD = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
        finally { [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
    }
    if (-not $env:ZHIYI_DB_PASSWORD) { Write-Bad 'ZHIYI_DB_PASSWORD is empty'; exit 1 }
    Write-Ok 'ZHIYI_DB_PASSWORD set (not printed)'

    # The JWT default in application.yml is a PUBLIC placeholder that is already
    # in the git history. Anyone who knows it can forge a token for any account,
    # admin included, so refuse to start with it unless told twice.
    $jwtDefault = 'zhiyi-manyou-dev-secret-key-please-change-in-production-2026'
    if (-not $env:ZHIYI_JWT_SECRET) {
        Write-WarnLine 'ZHIYI_JWT_SECRET not set - the backend would fall back to the'
        Write-Note  'public placeholder in application.yml. Fine on a LAN, NOT fine'
        Write-Note  'on the internet: a known secret means forgeable admin tokens.'
        $env:ZHIYI_JWT_SECRET = [guid]::NewGuid().ToString('N') + [guid]::NewGuid().ToString('N')
        Write-Ok 'generated a random JWT secret for THIS run (tokens die with it)'
    } elseif ($env:ZHIYI_JWT_SECRET -eq $jwtDefault) {
        Write-Bad 'ZHIYI_JWT_SECRET is still the public placeholder - refusing to start'
        Write-Note 'set a real random value: $env:ZHIYI_JWT_SECRET = [guid]::NewGuid().ToString("N")'
        exit 1
    } else {
        Write-Ok 'ZHIYI_JWT_SECRET set (not printed)'
    }

    if (-not (Test-Path -LiteralPath $jarPath)) {
        Write-Bad "backend jar missing: $jarPath"
        Write-Note 'build it: cd backend; mvn -o package -DskipTests'
        exit 1
    }
    Write-Ok 'backend jar present'

    if (-not (Test-Path -LiteralPath $frontDist)) {
        Write-WarnLine "frontend build missing: $frontDist"
        Write-Note 'build it: cd frontend; npm run build'
        $build = Read-Host '  build now? (y/N)'
        if ($build -eq 'y') {
            Push-Location $frontDir
            & npm run build
            Pop-Location
            if (-not (Test-Path -LiteralPath $frontDist)) { Write-Bad 'build did not produce dist/'; exit 1 }
            Write-Ok 'frontend built'
        } else {
            exit 1
        }
    } else {
        Write-Ok 'frontend build present'
    }

    $pythonExe = $null
    foreach ($cand in @(
        'G:\DEV\python-venv\Scripts\python.exe',
        (Join-Path $repoRoot 'nlp-service\.venv\Scripts\python.exe'),
        (Join-Path $repoRoot '.venv\Scripts\python.exe')
    )) {
        if (Test-Path -LiteralPath $cand) { $pythonExe = $cand; break }
    }
    if (-not $pythonExe) {
        $cmd = Get-Command 'python.exe' -ErrorAction SilentlyContinue
        if ($cmd) { $pythonExe = $cmd.Source }
    }
    if ($NoNlp) {
        Write-WarnLine 'semantic service skipped (-NoNlp): matching degrades to keywords only'
    } elseif (-not $pythonExe) {
        Write-Bad 'python.exe not found; set up the venv or pass -NoNlp'
        exit 1
    } else {
        Write-Ok "python: $pythonExe"
    }

    # ---------------- 1. port availability ----------------------------------
    Write-Host ''
    Write-Host '  [1/4] ports' -ForegroundColor Cyan
    $targets = @()
    if (-not $NoNlp) { $targets += @{ Port = $NlpPort; Title = $winNlp } }
    $targets += @{ Port = $BackendPort; Title = $winBackend }
    $targets += @{ Port = $FrontPort;   Title = $winFront }

    $busy = @()
    foreach ($t in $targets) {
        if (Test-PortListening -Port $t.Port) {
            $owner = Get-ListeningPid -Port $t.Port
            $busy += $t
            Write-WarnLine "port $($t.Port) already in use (PID $owner)"
        } else {
            Write-Ok "port $($t.Port) free"
        }
    }
    if ($busy.Count -gt 0) {
        Write-Host ''
        Write-Note 'those ports are already serving. Either use them as-is, or stop them:'
        Write-Note '  powershell -File .\scripts\start-all.ps1 -Stop'
        $ans = Read-Host '  stop them and continue? (y/N)'
        if ($ans -ne 'y') { Write-Host ''; Write-WarnLine 'aborted'; exit 1 }
        foreach ($t in $busy) {
            $owner = Get-ListeningPid -Port $t.Port
            if ($owner) {
                try { Stop-Process -Id $owner -Force -ErrorAction Stop; Write-Ok "stopped PID $owner on port $($t.Port)" }
                catch { Write-WarnLine "could not stop PID ${owner}: $($_.Exception.Message)" }
            }
        }
        Start-Sleep -Seconds 2
    }

    # ---------------- 2. start NLP ------------------------------------------
    Write-Host ''
    Write-Host '  [2/4] semantic service (NLP)' -ForegroundColor Cyan
    if ($NoNlp) {
        Write-WarnLine 'skipped'
    } else {
        $venvSite = Join-Path (Split-Path -Parent (Split-Path -Parent $pythonExe)) 'Lib\site-packages'
        $nlpLines = @()
        if (Test-Path -LiteralPath $venvSite) { $nlpLines += "set PYTHONPATH=$venvSite" }
        $nlpLines += 'set PYTHONIOENCODING=utf-8'
        $nlpLines += ('"{0}" "{1}" --port {2}' -f $pythonExe, $nlpScript, $NlpPort)
        $null = Start-ServiceWindow -Title $winNlp -CommandLines $nlpLines
        if (Wait-Http -Url "http://127.0.0.1:$NlpPort/health" -TimeoutSec 90) {
            Write-Ok "NLP healthy on $NlpPort"
        } else {
            Write-Bad "NLP did not become healthy within 90s (window: $winNlp)"
            Write-Note 'check that window; the app will fall back to keyword matching'
        }
    }

    # ---------------- 3. start backend --------------------------------------
    Write-Host ''
    Write-Host '  [3/4] backend' -ForegroundColor Cyan
    $javaExe = $null
    foreach ($cand in @('G:\DEV\jdk17\bin\java.exe')) {
        if (Test-Path -LiteralPath $cand) { $javaExe = $cand; break }
    }
    if (-not $javaExe) {
        $cmd = Get-Command 'java.exe' -ErrorAction SilentlyContinue
        if ($cmd) { $javaExe = $cmd.Source }
    }
    if (-not $javaExe) { Write-Bad 'java.exe not found (expected G:\DEV\jdk17)'; exit 1 }

    $backLines = @(
        "set ZHIYI_DB_HOST=$DbHost",
        "set ZHIYI_DB_PORT=$DbPort",
        "set ZHIYI_DB_NAME=$DbName",
        "set ZHIYI_DB_USER=$DbUser",
        "set ZHIYI_DB_PASSWORD=$($env:ZHIYI_DB_PASSWORD)",
        "set ZHIYI_JWT_SECRET=$($env:ZHIYI_JWT_SECRET)",
        "set ZHIYI_NLP_URL=http://127.0.0.1:$NlpPort",
        'set JAVA_TOOL_OPTIONS=',
        ('"{0}" -Dfile.encoding=UTF-8 -Duser.timezone=Asia/Shanghai -jar "{1}"' -f $javaExe, $jarPath)
    )
    $null = Start-ServiceWindow -Title $winBackend -CommandLines $backLines
    if (Wait-Http -Url "http://127.0.0.1:$BackendPort/api/health" -TimeoutSec 120) {
        Write-Ok "backend healthy on $BackendPort"
    } else {
        Write-Bad "backend did not become healthy within 120s (window: $winBackend)"
        Write-Note 'common causes: MySQL not running, wrong password, port taken'
        exit 1
    }

    # ---------------- 4. start frontend -------------------------------------
    Write-Host ''
    Write-Host '  [4/4] frontend' -ForegroundColor Cyan
    $frontLines = @(
        ('cd /d "{0}"' -f $frontDir),
        ('call npm run preview -- --port {0}' -f $FrontPort)
    )
    $null = Start-ServiceWindow -Title $winFront -CommandLines $frontLines
    if (Wait-Http -Url "http://127.0.0.1:$FrontPort/" -TimeoutSec 90) {
        Write-Ok "frontend healthy on $FrontPort"
    } else {
        Write-Bad "frontend did not become healthy within 90s (window: $winFront)"
        exit 1
    }

    # ---------------- verify the path a roommate actually uses ---------------
    Write-Host ''
    Write-Host '  [verify] end-to-end through the LAN address' -ForegroundColor Cyan
    $ipInfo = Get-LanIPv4
    if (-not $ipInfo.Ip) {
        Write-Bad 'no LAN IPv4 found (are you connected to Wi-Fi?)'
        exit 1
    }
    $lanUrl = "http://$($ipInfo.Ip):$FrontPort"

    if (Test-HttpOk -Url "$lanUrl/" -TimeoutSec 8) { Write-Ok "homepage  $lanUrl/" }
    else { Write-Bad "homepage unreachable at $lanUrl/ - Windows Firewall probably blocks port $FrontPort" }

    if (Test-HttpOk -Url "$lanUrl/api/health" -TimeoutSec 8) { Write-Ok "api proxy $lanUrl/api/health" }
    else { Write-Bad 'api proxy not answering through the frontend' }

    if (-not (Test-PortBoundAll -Port $FrontPort)) {
        Write-Bad "port $FrontPort is not bound to all interfaces - roommates cannot reach it"
    }

    # ---------------- summary ------------------------------------------------
    Write-Host ''
    Write-Host ('=' * 66)
    if ($script:fail -eq 0) {
        Write-Host "  $tAllOk" -ForegroundColor Green
    } else {
        Write-Host ("  {0} failed - see above" -f $script:fail) -ForegroundColor Red
    }
    Write-Host ('=' * 66)
    Write-Host ''
    Write-Host ("  $tUrl : $lanUrl/") -ForegroundColor Cyan
    Write-Host ("  $tAcct : 2024117420 / 123456    (admin / 123456)")
    Write-Host ''
    Write-Host "  $tSameWifi"
    Write-Host ''
    Write-Host '  service windows (check these if something looks wrong):' -ForegroundColor DarkGray
    Write-Host ("    {0,-16} NLP       -> http://127.0.0.1:{1}/health" -f $winNlp, $NlpPort) -ForegroundColor DarkGray
    Write-Host ("    {0,-16} backend   -> http://127.0.0.1:{1}/api/health" -f $winBackend, $BackendPort) -ForegroundColor DarkGray
    Write-Host ("    {0,-16} frontend  -> http://127.0.0.1:{1}/" -f $winFront, $FrontPort) -ForegroundColor DarkGray
    Write-Host ''
    Write-Host '  stop everything: powershell -File .\scripts\start-all.ps1 -Stop' -ForegroundColor DarkGray
    Write-Host '  re-check LAN   : powershell -File .\check-lan.ps1' -ForegroundColor DarkGray
    Write-Host ''
    exit ([int]($script:fail -gt 0))
}

switch ($Action) {
    'start'  { Invoke-Start }
    'stop'   { Invoke-Stop }
    'status' { Invoke-Status }
}
