# =============================================================================
#  ZhiYi Manyou - LAN preflight check   [ASCII-only file, see NOTE 1]
#
#  Verifies, from the perspective of a roommate on the same Wi-Fi, that the
#  site is actually reachable and usable -- not just "the process is running".
#
#  Usage:
#      powershell -ExecutionPolicy Bypass -File .\check-lan.ps1
#
#  Exit code: 0 = all checks passed, 1 = at least one failure.
#
#  NOTE 1: this file is intentionally ASCII-only, INCLUDING comments.
#          Windows PowerShell 5.1 reads .ps1 files as GBK on Chinese Windows
#          when they have no UTF-8 BOM, and multi-byte characters can shift the
#          parser and produce bogus syntax errors such as "Unexpected token ')'"
#          pointing at unrelated lines. A file that merely happens to work today
#          can break the moment its byte length changes, so keep it ASCII.
#          Chinese output is built from [char] codes at runtime instead.
#
#  NOTE 2: Chinese strings are built with a helper taking a typed [int[]]
#          parameter, NOT "helper @(1,2,3)". The inline-array form makes
#          PowerShell 5.1's parser treat the array as an argument list in some
#          contexts and fail with a misleading "Missing '=' operator after key
#          in hash literal" error pointing at an unrelated line.
#
#  NOTE 3: PowerShell variable names are case-insensitive. Do not use $home
#          (collides with the read-only built-in $HOME) or $pid (likewise).
# =============================================================================

[CmdletBinding()]
param(
    [int]$Port = 5173,
    [int]$BackendPort = 8080,
    [string]$TestSno = '2024117420',
    [string]$TestPassword = '123456'
)

$ErrorActionPreference = 'Continue'

# --- ASCII-only helper for Chinese output ------------------------------------
function New-Cn {
    param([int[]]$Codes)
    $sb = New-Object System.Text.StringBuilder
    foreach ($c in $Codes) { [void]$sb.Append([char]$c) }
    return $sb.ToString()
}

# --- static labels -----------------------------------------------------------
$tPass      = New-Cn @(36890, 36807)                             # tong guo
$tFail      = New-Cn @(22833, 36133)                            # shi bai
$tWarn      = New-Cn @(35686, 21578)                            # jing gao
$tIpAddr    = New-Cn @(26412, 26426, 73, 80)                    # ben ji IP
$tListen    = New-Cn @(30417, 21548)                            # jian ting
$tFrontend  = New-Cn @(21069, 31471, 39318, 39029)              # qian duan shou ye
$tApiProxy  = New-Cn @(25509, 21475, 20195, 29702)              # jie kou dai li
$tApiDirect = New-Cn @(21518, 31471, 30452, 36830)              # hou duan zhi lian
$tLogin     = New-Cn @(30331, 24405, 25509, 21475)              # deng lu jie kou
$tCors      = New-Cn @(36328, 22495, 21709, 24212)              # kua yu xiang ying
$tNlp       = New-Cn @(35821, 20041, 26381, 21153)              # yu yi fu wu
$tRoommate  = New-Cn @(23460, 21451, 35775, 38382, 22320, 22336) # shi you di zhi
$tTestAcc   = New-Cn @(27979, 35797, 36134, 21495)              # ce shi zhang hao

# --- hint sentences ----------------------------------------------------------
$hintSameWifi  = New-Cn @(20854, 20182, 35774, 22791, 38656, 19982, 20320, 21516, 19968, 32, 87, 105, 70, 105, 32, 32593, 27573)
$hintFirewall  = New-Cn @(38450, 28779, 22681, 38656, 25918, 34892, 35268, 21017, 65292, 38656, 31649, 29702, 21592, 26435, 38480)
$hintBoundAll  = New-Cn @(24050, 32465, 20840, 32593, 21345, 65292, 23616, 22495, 32593, 21487, 35265)
$hintOnlyLocal = New-Cn @(20165, 26412, 26426, 21487, 35265, 65292, 35831, 23558, 32, 118, 105, 116, 101, 46, 99, 111, 110, 102, 105, 103, 46, 116, 115, 32, 30340, 32, 104, 111, 115, 116, 32, 25913, 20026, 32, 48, 46, 48, 46, 48, 46, 48)
$hintNoFront   = New-Cn @(26410, 30417, 21548, 65292, 35831, 20808, 21551, 21160, 32, 110, 112, 109, 32, 114, 117, 110, 32, 112, 114, 101, 118, 105, 101, 119, 65288, 29983, 20135, 20135, 29289, 65292, 39318, 23631, 26356, 24555, 65289, 25110, 32, 110, 112, 109, 32, 114, 117, 110, 32, 100, 101, 118)
$hintNoBack    = New-Cn @(21518, 31471, 26410, 21551, 21160, 65292, 30331, 24405, 24517, 28982, 22833, 36133)
$hintNlpOn     = New-Cn @(24050, 21551, 21160, 65292, 35821, 20041, 25628, 32034, 21487, 29992)
$hintNlpOff    = New-Cn @(26410, 21551, 21160, 65292, 26234, 33021, 25277, 21462, 23558, 38477, 32423, 20026, 35268, 21017, 35789, 20856)
$hintNoIp      = New-Cn @(26410, 26816, 26597, 21040, 32593, 21345, 22320, 22336, 65292, 35831, 30830, 35748, 32, 87, 105, 70, 105, 32, 24050, 36830, 25509)
$hintCorsBad   = New-Cn @(39044, 26816, 26410, 36890, 36807, 32, 45, 45, 32, 27983, 35272, 22120, 20250, 30452, 25509, 25318, 25481, 32, 80, 79, 83, 84, 32, 35831, 27714)
$hintCors403   = New-Cn @(35831, 26816, 26597, 32, 83, 101, 99, 117, 114, 105, 116, 121, 67, 111, 110, 102, 105, 103, 32, 30340, 32, 122, 104, 105, 121, 105, 46, 99, 111, 114, 115, 32, 37197, 32622)
$hintNoResp    = New-Cn @(35831, 27714, 26410, 21457, 20986)
$hintAllOk     = New-Cn @(20840, 37096, 26816, 26597, 36890, 36807, 65292, 21487, 20197, 25226, 22320, 22336, 21457, 32473, 23460, 21451, 20102)
$hintSeeDoc    = New-Cn @(25490, 26597, 35828, 26126, 65306, 100, 111, 99, 115, 92, 23616, 22495, 32593, 37096, 32626, 35828, 26126, 46, 109, 100)
$hintSkip      = New-Cn @(26680, 24515, 26381, 21153, 26410, 23601, 32490, 65292, 21518, 32493, 26816, 26597, 24050, 36339, 36807)
$tViaProxy     = New-Cn @(32463, 20195, 29702)                  # jing dai li

$script:Failures = 0
$script:Warnings = 0

function Write-Step {
    param([string]$Name, [bool]$Ok, [string]$Detail)
    if ($Ok) {
        Write-Host ("  [{0}] {1}" -f $tPass, $Name) -ForegroundColor Green
    } else {
        Write-Host ("  [{0}] {1}" -f $tFail, $Name) -ForegroundColor Red
    }
    if ($Detail) { Write-Host ("        {0}" -f $Detail) -ForegroundColor Gray }
    if (-not $Ok) { $script:Failures = $script:Failures + 1 }
}

function Write-Warn {
    param([string]$Message)
    Write-Host ("  [{0}] {1}" -f $tWarn, $Message) -ForegroundColor Yellow
    $script:Warnings = $script:Warnings + 1
}

Write-Host ''
Write-Host '=== ZhiYi Manyou / LAN check ===' -ForegroundColor Cyan
Write-Host ''

# --- 1. local IPv4 -----------------------------------------------------------
$ips = @()
try {
    $found = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop
    $ips = @($found | Where-Object {
        $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*'
    } | Select-Object -ExpandProperty IPAddress)
} catch {
    # Fallback: parse ipconfig, which works without the NetTCPIP module.
    $lines = @(ipconfig | Select-String 'IPv4')
    $ips = @($lines | ForEach-Object {
        if ($_ -match '(\d+\.\d+\.\d+\.\d+)') { $matches[1] }
    } | Where-Object { $_ -notlike '127.*' -and $_ -notlike '169.254.*' })
}

$private = @($ips | Where-Object { $_ -match '^(10|192\.168|172\.(1[6-9]|2\d|3[01]))\.' })
$lanIp = $null
if ($private.Count -gt 0) { $lanIp = $private[0] }
elseif ($ips.Count -gt 0) { $lanIp = $ips[0] }

if ($lanIp) {
    Write-Step -Name ("{0}: {1}" -f $tIpAddr, $lanIp) -Ok $true
} else {
    Write-Step -Name ("{0}: <none>" -f $tIpAddr) -Ok $false -Detail $hintNoIp
}

# --- 2. listening sockets ----------------------------------------------------
$netstatText = (netstat -ano 2>$null | Select-String 'LISTENING') -join "`n"
$frontOk = $netstatText -match (":$Port\s")
$backOk = $netstatText -match (":$BackendPort\s")
$frontAll = $netstatText -match ("0\.0\.0\.0:$Port\s")

$frontDetail = $hintNoFront
if ($frontAll) { $frontDetail = $hintBoundAll }
elseif ($frontOk) { $frontDetail = $hintOnlyLocal }
Write-Step -Name ("{0} {1}" -f $tListen, $Port) -Ok $frontOk -Detail $frontDetail

$backDetail = $hintNoBack
if ($backOk) { $backDetail = "0.0.0.0:$BackendPort" }
Write-Step -Name ("{0} {1}" -f $tListen, $BackendPort) -Ok $backOk -Detail $backDetail

# --- 3. NLP service (optional, degrades gracefully) --------------------------
$nlpOk = $netstatText -match ':8901\s'
if ($nlpOk) {
    Write-Step -Name ("{0} 8901" -f $tNlp) -Ok $true -Detail $hintNlpOn
} else {
    Write-Warn -Message ("{0} 8901 - {1}" -f $tNlp, $hintNlpOff)
}

if (-not ($frontOk -and $backOk)) {
    Write-Host ''
    Write-Host $hintSkip -ForegroundColor Yellow
    exit 1
}

# --- HTTP helper -------------------------------------------------------------
function Invoke-Check {
    param(
        [string]$Url,
        [string]$Method = 'GET',
        [hashtable]$Headers = $null,
        [string]$Body = $null,
        [int]$TimeoutSec = 12
    )
    $callArgs = @{
        Uri             = $Url
        Method          = $Method
        UseBasicParsing = $true
        TimeoutSec      = $TimeoutSec
        ErrorAction     = 'Stop'
    }
    if ($Headers) { $callArgs['Headers'] = $Headers }
    if ($Body) { $callArgs['Body'] = $Body }
    try {
        $r = Invoke-WebRequest @callArgs
        return @{ ok = $true; status = [int]$r.StatusCode; body = $r.Content; headers = $r.Headers }
    } catch {
        $resp = $_.Exception.Response
        if ($resp) {
            $sr = New-Object System.IO.StreamReader($resp.GetResponseStream())
            return @{ ok = $false; status = [int]$resp.StatusCode; body = $sr.ReadToEnd(); headers = $resp.Headers }
        }
        return @{ ok = $false; status = 0; body = [string]$_.Exception.Message; headers = @{} }
    }
}

# --- 4. endpoints as seen from the LAN address -------------------------------
$base = "http://${lanIp}:${Port}"

$homePage = Invoke-Check -Url "$base/"
Write-Step -Name ("{0}  {1}/" -f $tFrontend, $base) -Ok ($homePage.ok -and $homePage.status -eq 200) `
    -Detail ("HTTP {0}, {1} bytes" -f $homePage.status, $homePage.body.Length)

$proxy = Invoke-Check -Url "$base/api/health"
$proxyCode = '?'
if ($proxy.ok) { try { $proxyCode = ($proxy.body | ConvertFrom-Json).code } catch { } }
Write-Step -Name ("{0}  {1}/api/health" -f $tApiProxy, $base) -Ok ($proxy.ok -and "$proxyCode" -eq '0') `
    -Detail ("HTTP {0}, code={1}" -f $proxy.status, $proxyCode)

$direct = Invoke-Check -Url "http://127.0.0.1:${BackendPort}/api/health"
Write-Step -Name ("{0}  http://127.0.0.1:{1}/api/health" -f $tApiDirect, $BackendPort) -Ok $direct.ok `
    -Detail ("HTTP {0}" -f $direct.status)

# --- 5. login + CORS with the LAN Origin (the 403 trap) ----------------------
#
# Probe the BACKEND port, not the Vite port, for the CORS check.
#
# Vite's dev proxy answers OPTIONS preflights itself (204, with its own
# Access-Control-Allow-Methods) and never forwards them upstream, so a
# preflight sent to :5173 tells us nothing about the backend's CORS whitelist.
# What decides whether the roommate can log in is how the backend reacts to a
# request carrying the LAN Origin -- and Vite does forward that request
# (changeOrigin rewrites Host, NOT Origin). This exact area produced a real bug:
# the private-range patterns were written as "http://10.[*].[*].[*]:[*]", which
# Spring 6 treats as a literal (OriginPattern honours [*] only in the PORT
# segment), so the rule silently never matched and every login POST returned
# "403 Invalid CORS request" while GETs looked perfectly fine.
# See SecurityConfig and backend/zy-server/src/test/java/.../config/CorsOriginTest.java

$origin = $base
$backendBase = "http://127.0.0.1:${BackendPort}"
$loginHeaders = @{ 'Origin' = $origin; 'Content-Type' = 'application/json' }
$loginBody = '{"sno":"' + $TestSno + '","password":"' + $TestPassword + '"}'
$loginName = "{0} ({1}, {2})" -f $tLogin, $TestSno, $tViaProxy

$login = Invoke-Check -Url "$base/api/auth/login" -Method 'POST' -Headers $loginHeaders -Body $loginBody
if ($login.status -eq 200) {
    $code = '?'
    try { $code = ($login.body | ConvertFrom-Json).code } catch { }
    Write-Step -Name $loginName -Ok ("$code" -eq '0') -Detail ("HTTP 200, code={0}" -f $code)
} elseif ($login.status -eq 403) {
    Write-Step -Name $loginName -Ok $false -Detail ('HTTP 403 Invalid CORS request - ' + $hintCors403)
} elseif ($login.status -eq 0) {
    Write-Step -Name $loginName -Ok $false -Detail $hintNoResp
} else {
    Write-Step -Name $loginName -Ok $false -Detail ("HTTP {0}" -f $login.status)
}

$pf = Invoke-Check -Url "$backendBase/api/auth/login" -Method 'OPTIONS' -Headers @{
    'Origin'                         = $origin
    'Access-Control-Request-Method'  = 'POST'
    'Access-Control-Request-Headers' = 'content-type'
}
$allowOrigin = ''
if ($pf.headers) { $allowOrigin = [string]$pf.headers['Access-Control-Allow-Origin'] }
$preflightOk = ($pf.status -eq 200 -and $allowOrigin -eq $origin)
$preflightDetail = $hintCorsBad
if ($preflightOk) { $preflightDetail = "Access-Control-Allow-Origin: $allowOrigin" }
Write-Step -Name ("{0}  OPTIONS -> :{1}" -f $tCors, $BackendPort) -Ok $preflightOk -Detail $preflightDetail

# --- 6. summary -------------------------------------------------------------
Write-Host ''
if ($script:Failures -eq 0) {
    Write-Host $hintAllOk -ForegroundColor Green
    Write-Host ''
    Write-Host ("  {0}: {1}/" -f $tRoommate, $base) -ForegroundColor Cyan
    Write-Host ("  {0}: {1} / {2}   (admin / {2})" -f $tTestAcc, $TestSno, $TestPassword) -ForegroundColor Gray
    Write-Host ''
    Write-Host ("  {0}" -f $hintSameWifi) -ForegroundColor Gray
    if ($script:Warnings -gt 0) {
        Write-Host ("  {0}: {1}" -f $tWarn, $script:Warnings) -ForegroundColor Yellow
    }
    exit 0
} else {
    Write-Host ("{0}: {1}" -f $tFail, $script:Failures) -ForegroundColor Red
    Write-Host ("  {0}" -f $hintFirewall) -ForegroundColor Gray
    Write-Host ("  {0}" -f $hintSeeDoc) -ForegroundColor Gray
    exit 1
}
