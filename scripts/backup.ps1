# =============================================================================
#  zhiyi-manyou :: database backup / restore tool   (FR-M9-06)
# =============================================================================
#  NOTE: This file is deliberately pure ASCII. Windows PowerShell 5.1 reads
#  .ps1 files as ANSI (GBK on zh-CN) unless they carry a UTF-8 BOM, and a BOM
#  breaks other tooling; keeping it ASCII avoids the whole class of problems.
#  Chinese notes live in scripts/README.md instead.
#
#  USAGE
#    pwsh -File scripts/backup.ps1 backup
#    pwsh -File scripts/backup.ps1 list
#    pwsh -File scripts/backup.ps1 verify -File backups/xxx.sql
#    pwsh -File scripts/backup.ps1 restore -File backups/xxx.sql -Db zhiyi_manyou -Force
#
#  PASSWORD
#    Read from $env:ZHIYI_DB_PASSWORD. If unset, prompted (never echoed,
#    never written to disk, never placed on the command line).
#
#  EXIT CODES
#    0 = ok        1 = failed        2 = bad usage
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('backup', 'restore', 'list', 'verify')]
    [string]$Action = 'backup',

    # --- connection ---------------------------------------------------------
    [string]$Database = $env:ZHIYI_DB_NAME,
    [string]$DbHost   = $env:ZHIYI_DB_HOST,
    [int]   $Port   = 0,
    [string]$User   = $env:ZHIYI_DB_USER,
    [string]$MysqlHome = $env:ZHIYI_MYSQL_HOME,

    # --- backup -------------------------------------------------------------
    [string]$OutDir    = '',
    [int]   $Keep      = 14,      # keep N newest backups; 0 = keep everything
    [switch]$NoCompress,

    # --- restore / verify ---------------------------------------------------
    [string]$File = '',

    # Restore into an existing database that already holds tables. Required
    # whenever the restore could destroy data, so it can never happen by typo.
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

# ----------------------------------------------------------------------------
# 0. resolve repo root and defaults
# ----------------------------------------------------------------------------
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot  = Split-Path -Parent $scriptDir

if ([string]::IsNullOrWhiteSpace($Database))   { $Database   = 'zhiyi_manyou' }
if ([string]::IsNullOrWhiteSpace($DbHost)) { $DbHost = 'localhost' }
if ($Port -le 0)                         { $Port = 3306 }
if ([string]::IsNullOrWhiteSpace($User)) { $User = 'root' }
if ([string]::IsNullOrWhiteSpace($OutDir)) { $OutDir = Join-Path $repoRoot 'backups' }

function Write-Step  ([string]$m) { Write-Host "[*] $m" -ForegroundColor Cyan }
function Write-Ok    ([string]$m) { Write-Host "[+] $m" -ForegroundColor Green }
function Write-Warn2 ([string]$m) { Write-Host "[!] $m" -ForegroundColor Yellow }
function Write-Err2  ([string]$m) { Write-Host "[x] $m" -ForegroundColor Red }

function Fail ([string]$m, [int]$code = 1) { Write-Err2 $m; exit $code }

# ----------------------------------------------------------------------------
# 1. locate the MySQL client tools
# ----------------------------------------------------------------------------
function Resolve-MysqlTool ([string]$exeName) {
    # 1) explicit override
    if (-not [string]::IsNullOrWhiteSpace($MysqlHome)) {
        $p = Join-Path $MysqlHome "bin\$exeName"
        if (Test-Path -LiteralPath $p) { return $p }
    }
    # 2) already on PATH
    $cmd = Get-Command $exeName -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    # 3) common install roots (this project's dev box keeps it in G:\DEV\mysql)
    $roots = @(
        'C:\Program Files\MySQL',
        'C:\Program Files (x86)\MySQL',
        'G:\DEV\mysql',
        'D:\DEV\mysql',
        'C:\mysql',
        'G:\mysql'
    )
    foreach ($r in $roots) {
        if (-not (Test-Path -LiteralPath $r)) { continue }
        $hit = Get-ChildItem -LiteralPath $r -Recurse -Filter $exeName -ErrorAction SilentlyContinue |
               Select-Object -First 1
        if ($hit) { return $hit.FullName }
    }
    return $null
}

# ----------------------------------------------------------------------------
# 2. credentials (never on the command line, never on disk)
# ----------------------------------------------------------------------------
function Get-DbPassword {
    if ($env:ZHIYI_DB_PASSWORD) { return $env:ZHIYI_DB_PASSWORD }
    $sec = Read-Host -Prompt "MySQL password for user '$User'" -AsSecureString
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
    try   { return [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
    finally { [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
}

# Puts the password into MYSQL_PWD for the child process only.
function New-MySqlEnv {
    $env:MYSQL_PWD = $DbPassword
}

function Get-Sha256 ([string]$path) {
    return (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
}

# Format a byte count for humans.
function Format-Size ([long]$bytes) {
    if ($bytes -ge 1GB) { return ('{0:N2} GB' -f ($bytes / 1GB)) }
    if ($bytes -ge 1MB) { return ('{0:N2} MB' -f ($bytes / 1MB)) }
    if ($bytes -ge 1KB) { return ('{0:N1} KB' -f ($bytes / 1KB)) }
    return "$bytes B"
}

# The schema version a dump was taken from, derived from the sql/01-schema.sql
# header comment when present. Purely informational, never used for logic.
function Get-SchemaStamp {
    $f = Join-Path $repoRoot 'sql\01-schema.sql'
    if (-not (Test-Path -LiteralPath $f)) { return 'unknown' }
    return (Get-Item -LiteralPath $f).LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
}

# ----------------------------------------------------------------------------
# 3. preflight
# ----------------------------------------------------------------------------
$dumpExe  = Resolve-MysqlTool 'mysqldump.exe'
$mysqlExe = Resolve-MysqlTool 'mysql.exe'
if (-not $dumpExe)  { Fail "mysqldump.exe not found. Set ZHIYI_MYSQL_HOME or pass -MysqlHome <dir>." }
if (-not $mysqlExe) { Fail "mysql.exe not found. Set ZHIYI_MYSQL_HOME or pass -MysqlHome <dir>." }

$DbPassword = Get-DbPassword
if ([string]::IsNullOrEmpty($DbPassword)) { Fail "empty password is not supported; set ZHIYI_DB_PASSWORD" }
New-MySqlEnv

# Args are passed as an ARRAY: PowerShell eats the dot in things like
# -Dfile.encoding and mangles single-token quoting, so never build one string.
$connArgs = @('-h', "$DbHost", '-P', "$Port", '-u', $User)

# ============================================================================
# ACTION: backup
# ============================================================================
function Invoke-Backup {
    if (-not (Test-Path -LiteralPath $OutDir)) {
        New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
    }

    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $base  = "$Database-$stamp"
    $sqlPath = Join-Path $OutDir "$base.sql"

    Write-Step "dumping database '$Database' from $DbHost`:$Port"

    # --single-transaction : consistent snapshot without locking MyISAM-free
    #                        InnoDB tables, so the dev server can keep serving.
    # --routines/--events  : schema completeness (stored procs are empty today
    #                        but a restore that silently drops them is a trap).
    # --no-tablespaces     : avoids needing PROCESS privilege on MySQL 8.
    # NOTE: --databases already emits CREATE DATABASE / USE, and mysqldump
    # wants at most one positional schema argument - so $Database is passed through
    # --databases ONLY. Adding a trailing positional $Database makes mysqldump look
    # for a table literally named after the schema and fail.
    $dumpArgs = @(
        '--single-transaction',
        '--routines',
        '--events',
        '--triggers',
        '--no-tablespaces',
        '--default-character-set=utf8mb4',
        '--hex-blob',
        '--set-gtid-purged=OFF',
        '--databases', $Database
    ) + $connArgs + @('--result-file', $sqlPath)

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $out = & $dumpExe @dumpArgs 2>&1
    $code = $LASTEXITCODE
    $sw.Stop()

    if ($code -ne 0) {
        if (Test-Path -LiteralPath $sqlPath) { Remove-Item -LiteralPath $sqlPath -Force }
        Fail "mysqldump failed (exit $code):`n$($out -join "`n")"
    }
    # mysqldump can exit 0 while having written a warning we must not ignore.
    if ($out) {
        foreach ($line in $out) {
            if ($line -match 'error|denied|warning' ) { Write-Warn2 "mysqldump: $line" }
        }
    }
    if (-not (Test-Path -LiteralPath $sqlPath)) { Fail "mysqldump reported success but wrote no file" }

    $raw = (Get-Item -LiteralPath $sqlPath).Length
    if ($raw -lt 1024) { Fail "dump is only $raw bytes; refusing to keep an empty backup" }

    # --- integrity -----------------------------------------------------------
    # $sha records the *.sql* content (stable across compression choices, and
    # what metadata readers care about). The sidecar <artifact>.sha256 records
    # whichever FILE actually survives on disk, so `list` and `restore` can
    # verify the bytes they are really about to use - including a .zip.
    $sha = Get-Sha256 $sqlPath

    # --- metadata (what was in it, so a restore is auditable) ----------------
    $counts = @{}
    $countSql = "SELECT TABLE_NAME, TABLE_ROWS FROM information_schema.TABLES WHERE TABLE_SCHEMA='$Database' AND TABLE_ROWS > 0 ORDER BY TABLE_ROWS DESC LIMIT 8"
    try {
        $rows = @(& $mysqlExe --default-character-set=utf8mb4 @connArgs -N -e $countSql 2>$null)
        foreach ($r in $rows) {
            $parts = $r -split "`t"
            if ($parts.Count -ge 2) { $counts[$parts[0]] = [int]$parts[1] }
        }
    } catch { Write-Warn2 "could not read row counts (non-fatal)" }

    $tableCount = 0
    try {
        $tc = @(& $mysqlExe @connArgs -N -e "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA='$Database' AND TABLE_TYPE='BASE TABLE'" 2>$null)
        if ($tc) { $tableCount = [int]($tc | Select-Object -First 1) }
    } catch { }

    $meta = [ordered]@{
        database     = $Database
        host         = $DbHost
        port         = $Port
        takenAt      = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        schemaStamp  = (Get-SchemaStamp)
        mysqldump    = (& $dumpExe --version 2>&1 | Select-Object -First 1)
        elapsedMs    = [int]$sw.ElapsedMilliseconds
        sizeBytes    = $raw
        tableCount   = $tableCount
        topTables    = $counts
        sha256       = $sha
        file         = (Split-Path -Leaf $sqlPath)
    }

    # --- compress ------------------------------------------------------------
    $finalPath = $sqlPath
    if (-not $NoCompress) {
        try {
            $zipPath = "$sqlPath.zip"
            Compress-Archive -LiteralPath $sqlPath -DestinationPath $zipPath -CompressionLevel Optimal -Force
            Remove-Item -LiteralPath $sqlPath -Force
            $finalPath = $zipPath
            Write-Ok "compressed -> $(Split-Path -Leaf $zipPath) ($(Format-Size (Get-Item -LiteralPath $zipPath).Length))"
        } catch {
            Write-Warn2 "compression failed, keeping the raw .sql ($($_.Exception.Message))"
        }
    }

    # Sidecars are written AFTER compression and named after the artifact that
    # actually survived, so <artifact>.sha256 always describes an existing file
    # and the filename shown by `list` can be copied straight into -File.
    $sideSha  = "$finalPath.sha256"
    $sideMeta = "$finalPath.meta.json"
    ($meta | ConvertTo-Json -Depth 4) | Set-Content -LiteralPath $sideMeta -Encoding UTF8
    Set-Content -LiteralPath $sideSha -Value (Get-Sha256 $finalPath) -Encoding Ascii -NoNewline

    # --- retention -----------------------------------------------------------
    if ($Keep -gt 0) {
        $all = @(Get-ChildItem -LiteralPath $OutDir -File |
               Where-Object { $_.Name -like "$Database-*.sql" -or $_.Name -like "$Database-*.sql.zip" } |
               Sort-Object LastWriteTime -Descending)
        $stale = @($all | Select-Object -Skip $Keep)
        foreach ($s in $stale) {
            foreach ($companion in @($s.FullName, "$($s.FullName).sha256", "$($s.FullName).meta.json")) {
                if (Test-Path -LiteralPath $companion) { Remove-Item -LiteralPath $companion -Force }
            }
            Write-Warn2 "retention: removed $(Split-Path -Leaf $s.Name)"
        }
    }

    Write-Ok "backup ok: $(Split-Path -Leaf $finalPath)"
    Write-Host "    path   : $finalPath"
    Write-Host "    size   : $(Format-Size (Get-Item -LiteralPath $finalPath).Length)  (raw $raw bytes)"
    Write-Host "    tables : $tableCount"
    Write-Host "    sha256 : $sha"
    Write-Host "    took   : $([int]$sw.ElapsedMilliseconds) ms"
    if ($counts.Count -gt 0) {
        Write-Host "    rows   :"
        foreach ($k in $counts.Keys) { Write-Host ("             {0,-32} {1}" -f $k, $counts[$k]) }
    }
    exit 0
}

# ============================================================================
# ACTION: list
# ============================================================================
function Invoke-List {
    if (-not (Test-Path -LiteralPath $OutDir)) {
        Write-Warn2 "no backup directory yet: $OutDir"
        exit 0
    }
    # @() is not decoration: under Set-StrictMode a single match must still be
    # an array, otherwise $files.Count throws PropertyNotFoundStrict.
    $files = @(Get-ChildItem -LiteralPath $OutDir -File |
             Where-Object { $_.Name -like '*.sql' -or $_.Name -like '*.sql.zip' } |
             Sort-Object LastWriteTime -Descending)
    if ($files.Count -eq 0) { Write-Warn2 "no backups in $OutDir"; exit 0 }

    Write-Host ""
    Write-Host ("{0,-42} {1,12} {2,20} {3}" -f 'FILE', 'SIZE', 'TAKEN AT', 'INTEGRITY')
    Write-Host ('-' * 92)
    foreach ($f in $files) {
        # every artifact has a <artifact>.sha256 sidecar, .zip included, so a
        # compressed backup is verifiable without expanding it first
        $shaF  = "$($f.FullName).sha256"
        $state = 'no .sha256'
        if (Test-Path -LiteralPath $shaF) {
            $want = (Get-Content -LiteralPath $shaF -Raw).Trim()
            $got  = Get-Sha256 $f.FullName
            $state = if ($got -eq $want) { 'OK' } else { 'MISMATCH' }
        }
        Write-Host ("{0,-42} {1,12} {2,20} {3}" -f $f.Name, (Format-Size $f.Length), $f.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'), $state)
    }
    Write-Host ""
    Write-Host "    total: $($files.Count) backup(s), $([int](($files | Measure-Object Length -Sum).Sum / 1MB)) MB"
    exit 0
}

# ============================================================================
# ACTION: verify
# ============================================================================
function Invoke-Verify {
    if ([string]::IsNullOrWhiteSpace($File)) { Fail "verify needs -File <backup.sql|backup.sql.zip>" 2 }
    if (-not (Test-Path -LiteralPath $File)) { Fail "file not found: $File" }

    $full = (Resolve-Path -LiteralPath $File).Path
    Write-Step "verifying $full"

    # sidecar is named after the artifact itself, so this works for .sql and
    # for the .zip that is normally kept
    $shaF = "$full.sha256"
    $got  = Get-Sha256 $full
    if (-not (Test-Path -LiteralPath $shaF)) {
        Write-Warn2 "no recorded checksum next to this file; reporting the computed one only"
        Write-Host "    sha256 : $got"
        exit 0
    }
    $want = (Get-Content -LiteralPath $shaF -Raw).Trim()
    if ($got -ne $want) {
        Write-Err2 "CHECKSUM MISMATCH"
        Write-Host "    expected: $want"
        Write-Host "    actual  : $got"
        exit 1
    }
    Write-Ok "checksum matches: $got"

    # A dump with no CREATE TABLE is useless however intact the bytes are, so
    # look inside - expanding the archive mentally is not verification.
    if ($full -like '*.zip') {
        try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            $zip = [System.IO.Compression.ZipFile]::OpenRead($full)
            try {
                $entry = $zip.Entries | Where-Object { $_.Name -like '*.sql' } | Select-Object -First 1
                if (-not $entry) { Write-Warn2 "archive contains no .sql entry"; exit 1 }
                $reader = New-Object System.IO.StreamReader($entry.Open())
                try {
                    $probe = ''
                    for ($i = 0; $i -lt 400 -and -not $reader.EndOfStream; $i++) {
                        $probe += $reader.ReadLine() + "`n"
                    }
                } finally { $reader.Dispose() }
                if ($probe -match 'CREATE TABLE') { Write-Ok "contains CREATE TABLE (entry: $($entry.Name))" }
                else { Write-Warn2 "no CREATE TABLE in the first 400 lines of $($entry.Name)"; exit 1 }
            } finally { $zip.Dispose() }
        } catch { Write-Warn2 "could not inspect archive: $($_.Exception.Message)"; exit 1 }
    } else {
        $head = Get-Content -LiteralPath $full -TotalCount 400
        if ($head | Select-String -Pattern 'CREATE TABLE' -Quiet) { Write-Ok "contains CREATE TABLE statements" }
        else { Write-Warn2 "no CREATE TABLE in the first 400 lines - check the dump"; exit 1 }
    }
    exit 0
}

# ============================================================================
# ACTION: restore
# ============================================================================
function Invoke-Restore {
    if ([string]::IsNullOrWhiteSpace($File)) { Fail "restore needs -File <backup.sql|backup.sql.zip>" 2 }
    if (-not (Test-Path -LiteralPath $File)) { Fail "file not found: $File" }

    $full = (Resolve-Path -LiteralPath $File).Path
    $artifact = $full
    $expectedSqlSha = $null

    # One scratch directory for the whole restore: the expanded dump (when the
    # artifact is a .zip) and the retargeted copy. Removed on every exit path.
    $workDir = Join-Path ([System.IO.Path]::GetTempPath()) ("zhiyi-restore-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $workDir -Force | Out-Null

    # Verify the artifact BEFORE doing anything else. Restoring a corrupt dump
    # on top of good data is exactly the disaster this tool exists to prevent,
    # and a .zip is normally the artifact that survives on disk.
    $shaF = "$artifact.sha256"
    if (Test-Path -LiteralPath $shaF) {
        $want = (Get-Content -LiteralPath $shaF -Raw).Trim()
        $got  = Get-Sha256 $artifact
        if ($got -ne $want) { Fail "checksum mismatch on $(Split-Path -Leaf $artifact), refusing to restore`n  expected $want`n  actual   $got" }
        Write-Ok "checksum verified: $(Split-Path -Leaf $artifact)"
    } else {
        Write-Warn2 "no .sha256 beside $(Split-Path -Leaf $artifact); restoring unverified"
    }

    # The sidecar describes the artifact; the .meta.json describes the SQL
    # inside it, so an archive that decompresses cleanly but to the wrong
    # content is still caught.
    if (Test-Path -LiteralPath "$artifact.meta.json") {
        try {
            $metaJson = Get-Content -LiteralPath "$artifact.meta.json" -Raw | ConvertFrom-Json
            if ($metaJson.sha256) { $expectedSqlSha = $metaJson.sha256 }
        } catch { Write-Warn2 "could not read .meta.json ($($_.Exception.Message))" }
    }

    if ($artifact -like '*.zip') {
        Write-Step "expanding archive"
        Expand-Archive -LiteralPath $artifact -DestinationPath $workDir -Force
        $found = @(Get-ChildItem -LiteralPath $workDir -Filter '*.sql' -File)
        if ($found.Count -eq 0) { Fail "archive contains no .sql file" }
        $full = $found[0].FullName
    }

    if ($expectedSqlSha) {
        $gotSql = Get-Sha256 $full
        if ($gotSql -ne $expectedSqlSha) {
            Remove-Item -LiteralPath $workDir -Recurse -Force -ErrorAction SilentlyContinue
            Fail "SQL content does not match what .meta.json recorded`n  expected $expectedSqlSha`n  actual   $gotSql"
        }
        Write-Ok "SQL content matches .meta.json"
    }

    # ------------------------------------------------------------------
    # Retarget the dump. `mysqldump --databases` bakes "CREATE DATABASE
    # <original>; USE <original>;" into the file, so without this step a
    # restore into any OTHER database name silently writes into the original
    # one (or fails outright). Rewriting also makes the common disasters
    # work: "restore last night's dump into zhiyi_manyou" and "spin the dump
    # up as zhiyi_restore_test to look at it".
    # ------------------------------------------------------------------
    $workSql = Join-Path $workDir 'retargeted.sql'

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $reader = New-Object System.IO.StreamReader($full, $utf8NoBom, $true)
    $writer = New-Object System.IO.StreamWriter($workSql, $false, $utf8NoBom)
    $stripped = 0
    try {
        # mysql creates the schema itself so the very first statements can run
        $writer.WriteLine("CREATE DATABASE IF NOT EXISTS ``$Database`` DEFAULT CHARACTER SET utf8mb4;")
        $writer.WriteLine("USE ``$Database``;")
        while ($null -ne ($line = $reader.ReadLine())) {
            if ($line -match '^\s*USE\s+`') { $stripped++; continue }
            if ($line -match '^\s*CREATE\s+DATABASE') { $stripped++; continue }
            # the comment header repeats the old name; drop it so a restored
            # dump cannot be misread as still describing the source database
            if ($line -match '^--\s+Current Database:') { $stripped++; continue }
            $writer.WriteLine($line)
        }
    } finally {
        $reader.Dispose()
        $writer.Dispose()
    }
    Write-Step "retargeted dump to '$Database' ($stripped statement(s) rewritten)"

    # Does the target already hold tables? If yes, -Force is mandatory.
    $existing = @(& $mysqlExe @connArgs -N -e "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA='$Database'" 2>$null)
    $existingCount = 0
    if ($existing) { $existingCount = [int]($existing | Select-Object -First 1) }

    if ($existingCount -gt 0 -and -not $Force) {
        Remove-Item -LiteralPath $workDir -Recurse -Force -ErrorAction SilentlyContinue
        Fail "database '$Database' already has $existingCount table(s). Re-run with -Force to overwrite." 2
    }

    Write-Step "restoring into '$Database' on $DbHost`:$Port"
    if ($existingCount -gt 0) { Write-Warn2 "overwriting $existingCount existing table(s)" }

    # Pipe the file on stdin through cmd.exe. Using Get-Content | mysql would
    # re-encode every line and corrupt utf8mb4 content - this project's data is
    # almost entirely Chinese skill names.
    $cmdLine = '"{0}" --default-character-set=utf8mb4 -h "{1}" -P {2} -u "{3}" < "{4}"' -f `
        $mysqlExe, $DbHost, $Port, $User, $workSql
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $out = @(& cmd.exe /c $cmdLine 2>&1)
    $code = $LASTEXITCODE
    $sw.Stop()

    Remove-Item -LiteralPath $workDir -Recurse -Force -ErrorAction SilentlyContinue

    if ($code -ne 0) { Fail "mysql restore failed (exit $code):`n$($out -join "`n")" }
    foreach ($line in $out) { if ($line -match 'ERROR') { Write-Warn2 "mysql: $line" } }

    # post-restore sanity: tables must exist and the skill table must be populated
    $after = @(& $mysqlExe --default-character-set=utf8mb4 @connArgs -N -e "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA='$Database' AND TABLE_TYPE='BASE TABLE'" 2>$null)
    $afterTables = if ($after) { [int]($after | Select-Object -First 1) } else { 0 }
    $skillRows = @(& $mysqlExe --default-character-set=utf8mb4 @connArgs -N -e "SELECT COUNT(*) FROM ``$Database``.zy_skill" 2>$null)
    $skills = if ($skillRows) { [int]($skillRows | Select-Object -First 1) } else { 0 }

    if ($afterTables -eq 0) { Fail "restore finished but the database has no tables" }

    Write-Ok "restore ok"
    Write-Host "    tables : $afterTables"
    Write-Host "    zy_skill rows : $skills"
    Write-Host "    took   : $([int]$sw.ElapsedMilliseconds) ms"
    if ($skills -eq 0) { Write-Warn2 "zy_skill is empty - the dump may have been schema-only" }
    exit 0
}

# ----------------------------------------------------------------------------
# dispatch
# ----------------------------------------------------------------------------
switch ($Action) {
    'backup'  { Invoke-Backup }
    'list'    { Invoke-List }
    'verify'  { Invoke-Verify }
    'restore' { Invoke-Restore }
}
