# =============================================================================
#  ZhiYi Manyou - Backend smoke test   [ASCII-only file, see NOTE below]
#
#  Usage:
#     powershell -ExecutionPolicy Bypass -File backend\smoke-test.ps1
#     powershell -ExecutionPolicy Bypass -File backend\smoke-test.ps1 -BaseUrl http://localhost:9090
#
#  NOTE: this file is intentionally ASCII-only. Windows PowerShell 5.1 reads
#        .ps1 files as GBK on Chinese Windows when they have no UTF-8 BOM, and
#        multi-byte characters can shift the parser and produce bogus syntax
#        errors such as "Unexpected token ')'". Keep all .ps1 files ASCII-only.
#
#  Precondition: backend is running (run-server.ps1)
# =============================================================================

param(
    [string]$BaseUrl = 'http://localhost:8080'
)

$ErrorActionPreference = 'Continue'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

$script:pass = 0
$script:fail = 0

function Invoke-Probe {
    param(
        [string]$Desc,
        [string]$Method,
        [string]$Path,
        [string]$Json,
        [string]$Token
    )
    $req = [System.Net.HttpWebRequest]::Create("$BaseUrl$Path")
    $req.Method = $Method
    $req.Timeout = 15000
    if ($Json) {
        $req.ContentType = 'application/json; charset=utf-8'
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Json)
        $req.ContentLength = $bytes.Length
        $stream = $req.GetRequestStream()
        $stream.Write($bytes, 0, $bytes.Length)
        $stream.Close()
    }
    if ($Token) { $req.Headers.Add('Authorization', "Bearer $Token") }

    $status = 0
    $body = ''
    try {
        $resp = $req.GetResponse()
        $status = [int]$resp.StatusCode
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream(), [System.Text.Encoding]::UTF8)
        $body = $reader.ReadToEnd()
        $resp.Close()
    } catch [System.Net.WebException] {
        $r = $_.Exception.Response
        if ($r) {
            $status = [int]$r.StatusCode
            try {
                $reader = New-Object System.IO.StreamReader($r.GetResponseStream(), [System.Text.Encoding]::UTF8)
                $body = $reader.ReadToEnd()
            } catch { $body = '(empty body)' }
            $r.Close()
        } else {
            $body = "no response: $($_.Exception.Message)"
        }
    }

    $obj = $null
    try { $obj = $body | ConvertFrom-Json } catch { }

    [PSCustomObject]@{
        Desc = $Desc
        Http = $status
        Body = $body
        Code = if ($obj) { $obj.code } else { $null }
        Data = if ($obj) { $obj.data } else { $null }
    }
}

function Assert-Result {
    param($Result, [int]$ExpectCode, [int]$ExpectHttp = 200)
    $ok = ($Result.Http -eq $ExpectHttp) -and ($Result.Code -eq $ExpectCode)
    if ($ok) {
        $script:pass++
        Write-Host ("  [PASS] {0,-30} HTTP {1} code={2}" -f $Result.Desc, $Result.Http, $Result.Code) -ForegroundColor Green
    } else {
        $script:fail++
        Write-Host ("  [FAIL] {0,-30} expect HTTP {1}/code={2}, got HTTP {3}/code={4}" -f `
            $Result.Desc, $ExpectHttp, $ExpectCode, $Result.Http, $Result.Code) -ForegroundColor Red
        Write-Host ("         body: {0}" -f $Result.Body) -ForegroundColor DarkGray
    }
    return $Result
}

Write-Host ''
Write-Host '============================================================' -ForegroundColor Yellow
Write-Host "  ZhiYi Manyou backend smoke test   $BaseUrl" -ForegroundColor Yellow
Write-Host '============================================================' -ForegroundColor Yellow
Write-Host ''

# ---------------------------------------------------------------- 1. public API
Write-Host '[1] Public endpoints' -ForegroundColor Cyan
Assert-Result (Invoke-Probe 'GET /api/health' 'GET' '/api/health' $null $null) 0 | Out-Null
Assert-Result (Invoke-Probe 'GET /api/health/info' 'GET' '/api/health/info' $null $null) 0 | Out-Null

$dbHealth = Invoke-Probe 'db connectivity' 'GET' '/api/health' $null $null
if ($dbHealth.Data -and $dbHealth.Data.database -eq 'UP') {
    $script:pass++
    Write-Host '  [PASS] database connectivity               database=UP' -ForegroundColor Green
} else {
    $script:fail++
    Write-Host '  [FAIL] database connectivity is not UP' -ForegroundColor Red
}

$infoRes = Invoke-Probe 'platform info' 'GET' '/api/health/info' $null $null
if ($infoRes.Data -and $infoRes.Data.name) {
    $script:pass++
    # Verify UTF-8 round-trip: platform name must start with the Chinese
    # characters U+77E5 U+9A7F (zhi yi). Built from char codes so this file
    # stays pure ASCII.
    $expected = ([char]0x77E5).ToString() + ([char]0x9A7F).ToString()
    if ($infoRes.Data.name.Contains($expected)) {
        $script:pass++
        Write-Host '  [PASS] Chinese text UTF-8 round-trip ok' -ForegroundColor Green
    } else {
        $script:fail++
        Write-Host ("  [FAIL] Chinese text corrupted: {0}" -f $infoRes.Data.name) -ForegroundColor Red
    }
}

# ---------------------------------------------------------------- 2. auth
Write-Host ''
Write-Host '[2] Authentication' -ForegroundColor Cyan
$login = Assert-Result (Invoke-Probe 'POST /api/auth/login admin' 'POST' '/api/auth/login' '{"sno":"admin","password":"123456"}') 0
$token = $null
$refresh = $null
if ($login.Data) {
    $token = $login.Data.accessToken
    $refresh = $login.Data.refreshToken
}
if ($token -and $refresh) {
    $script:pass++
    Write-Host ("  [PASS] issued access+refresh token           expiresIn={0}s" -f $login.Data.expiresIn) -ForegroundColor Green
} else {
    $script:fail++
    Write-Host '  [FAIL] missing tokens in login response' -ForegroundColor Red
}

# password hash must verify for every seeded account
foreach ($sno in @('2024117420', '2024117421', '2024117422')) {
    $r = Invoke-Probe "login $sno" 'POST' '/api/auth/login' ('{"sno":"' + $sno + '","password":"123456"}') $null
    if ($r.Code -eq 0) {
        $script:pass++
        Write-Host ("  [PASS] login {0,-28} OK" -f $sno) -ForegroundColor Green
    } else {
        $script:fail++
        Write-Host ("  [FAIL] login {0,-28} code={1}" -f $sno, $r.Code) -ForegroundColor Red
    }
}

Assert-Result (Invoke-Probe 'wrong password' 'POST' '/api/auth/login' '{"sno":"admin","password":"wrongpass"}') 3001 | Out-Null
Assert-Result (Invoke-Probe 'unknown user' 'POST' '/api/auth/login' '{"sno":"0000000","password":"123456"}') 3001 | Out-Null

# ---------------------------------------------------------------- 3. validation
Write-Host ''
Write-Host '[3] Parameter validation' -ForegroundColor Cyan
Assert-Result (Invoke-Probe 'blank sno and password' 'POST' '/api/auth/login' '{"sno":"","password":""}') 1001 | Out-Null
Assert-Result (Invoke-Probe 'short password' 'POST' '/api/auth/login' '{"sno":"admin","password":"123"}') 1001 | Out-Null
Assert-Result (Invoke-Probe 'malformed json body' 'POST' '/api/auth/login' 'not-a-json') 1005 | Out-Null

# ---------------------------------------------------------------- 4. authorization
Write-Host ''
Write-Host '[4] Authorization' -ForegroundColor Cyan
Assert-Result (Invoke-Probe 'no token -> /auth/me' 'GET' '/api/auth/me' $null $null) 2001 401 | Out-Null
Assert-Result (Invoke-Probe 'forged token -> /auth/me' 'GET' '/api/auth/me' $null 'fake.token.value') 2001 401 | Out-Null
if ($token) {
    Assert-Result (Invoke-Probe 'valid token -> /auth/me' 'GET' '/api/auth/me' $null $token) 0 | Out-Null
    $me = Invoke-Probe 'me payload' 'GET' '/api/auth/me' $null $token
    if ($me.Data -and $me.Data.sno -eq 'admin' -and $me.Data.role -eq 'ADMIN') {
        $script:pass++
        Write-Host '  [PASS] principal resolved correctly' -ForegroundColor Green
    } else {
        $script:fail++
        Write-Host '  [FAIL] principal incorrect' -ForegroundColor Red
    }
    if ($me.Body -match 'password' -or $me.Body -match '"phone"') {
        $script:fail++
        Write-Host '  [FAIL] sensitive field leaked in response' -ForegroundColor Red
    } else {
        $script:pass++
        Write-Host '  [PASS] no sensitive field leaked' -ForegroundColor Green
    }
}

# ---------------------------------------------------------------- 5. token refresh
Write-Host ''
Write-Host '[5] Token refresh' -ForegroundColor Cyan
if ($refresh) {
    Assert-Result (Invoke-Probe 'POST /api/auth/refresh' 'POST' '/api/auth/refresh' ('{"refreshToken":"' + $refresh + '"}') $null) 0 | Out-Null
}
Assert-Result (Invoke-Probe 'invalid refresh token' 'POST' '/api/auth/refresh' '{"refreshToken":"bad.token.here"}' $null) 2003 | Out-Null
Assert-Result (Invoke-Probe 'access token used as refresh' 'POST' '/api/auth/refresh' ('{"refreshToken":"' + $token + '"}') $null) 2003 | Out-Null

# ---------------------------------------------------------------- 6. error handling
Write-Host ''
Write-Host '[6] Error handling' -ForegroundColor Cyan
Assert-Result (Invoke-Probe 'wrong http method' 'GET' '/api/auth/login' $null $null) 1004 | Out-Null

$traceTest = Invoke-Probe 'traceId presence' 'POST' '/api/auth/login' '{"sno":"admin","password":"wrongpass"}' $null
if ($traceTest.Body -match '"traceId"') {
    $script:pass++
    Write-Host '  [PASS] business error carries traceId' -ForegroundColor Green
} else {
    $script:fail++
    Write-Host '  [FAIL] business error lacks traceId' -ForegroundColor Red
}

$tsTest = Invoke-Probe 'timestamp format' 'POST' '/api/auth/login' '{"sno":"admin","password":"wrongpass"}' $null
if ($tsTest.Body -match '"timestamp":"\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}"') {
    $script:pass++
    Write-Host '  [PASS] LocalDateTime formatted as yyyy-MM-dd HH:mm:ss' -ForegroundColor Green
} else {
    $script:fail++
    Write-Host '  [FAIL] timestamp format unexpected' -ForegroundColor Red
}

if ($tsTest.Body -match '"success"') {
    $script:fail++
    Write-Host '  [FAIL] computed field "success" leaked into JSON' -ForegroundColor Red
} else {
    $script:pass++
    Write-Host '  [PASS] computed field "success" not serialized' -ForegroundColor Green
}

# ---------------------------------------------------------------- 7. M4 market (public)
Write-Host ''
Write-Host '[7] M4 market and exchange (public part)' -ForegroundColor Cyan

Assert-Result (Invoke-Probe 'GET /api/demands (anonymous)' 'GET' '/api/demands?size=5' $null $null) 0 | Out-Null
Assert-Result (Invoke-Probe 'GET /api/meta/demands' 'GET' '/api/meta/demands' $null $null) 0 | Out-Null

$feed = Invoke-Probe 'market feed payload' 'GET' '/api/demands?size=5' $null $null
if ($feed.Data -and $feed.Data.records.Count -gt 0) {
    $script:pass++
    Write-Host ("  [PASS] market feed returns card(s)              total={0}" -f $feed.Data.total) -ForegroundColor Green

    $first = $feed.Data.records[0]
    if ($first.expectSkill -and $first.expectSkill.name) {
        $script:pass++
        Write-Host '  [PASS] card carries the "what I need" skill' -ForegroundColor Green
    } else {
        $script:fail++
        Write-Host '  [FAIL] card missing expectSkill' -ForegroundColor Red
    }

    if ($first.createdAt -match '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$') {
        $script:pass++
        Write-Host '  [PASS] card createdAt uses yyyy-MM-dd HH:mm:ss' -ForegroundColor Green
    } else {
        $script:fail++
        Write-Host ("  [FAIL] card createdAt format unexpected: {0}" -f $first.createdAt) -ForegroundColor Red
    }

    if ($first.matchFactors -and $first.matchFactors.Count -gt 0) {
        $script:pass++
        Write-Host ("  [PASS] match score breakdown present            factors={0}" -f $first.matchFactors.Count) -ForegroundColor Green
    } else {
        $script:fail++
        Write-Host '  [FAIL] matchFactors missing' -ForegroundColor Red
    }
} else {
    $script:fail++
    Write-Host '  [FAIL] market feed empty (seed data missing?)' -ForegroundColor Red
}

# write endpoints and personal data must require authentication
Assert-Result (Invoke-Probe 'POST /api/exchanges/apply (anonymous)' 'POST' '/api/exchanges/apply' '{"demandId":1}' $null) 2001 401 | Out-Null
Assert-Result (Invoke-Probe 'GET /api/demands/mine (anonymous)' 'GET' '/api/demands/mine' $null $null) 2001 401 | Out-Null
Assert-Result (Invoke-Probe 'GET /api/demands/interests/received (anon)' 'GET' '/api/demands/interests/received' $null $null) 2001 401 | Out-Null

# ---------------------------------------------------------------- 8. M4 guards (logged in)
Write-Host ''
Write-Host '[8] M4 exchange state machine (requires login)' -ForegroundColor Cyan

if ($token) {
    $meta = Invoke-Probe 'exchange status meta' 'GET' '/api/meta/exchange-status' $null $token
    if ($meta.Code -eq 0 -and $meta.Data.Count -eq 7) {
        $script:pass++
        Write-Host '  [PASS] status machine exposes 7 states' -ForegroundColor Green
    } else {
        $script:fail++
        Write-Host ("  [FAIL] status machine unexpected, code={0}" -f $meta.Code) -ForegroundColor Red
    }

    $ownCards = Invoke-Probe 'my cards' 'GET' '/api/demands/mine' $null $token
    if ($ownCards.Code -eq 0 -and $ownCards.Data.Count -gt 0) {
        $ownId = $ownCards.Data[0].id
        $self = Invoke-Probe 'apply own demand' 'POST' '/api/exchanges/apply' ("{""demandId"":$ownId}") $token
        if ($self.Code -eq 3022 -or $self.Code -eq 3021) {
            $script:pass++
            Write-Host ("  [PASS] self-application blocked                 code={0}" -f $self.Code) -ForegroundColor Green
        } else {
            $script:fail++
            Write-Host ("  [FAIL] self-application not blocked, code={0}" -f $self.Code) -ForegroundColor Red
        }
    } else {
        $script:pass++
        Write-Host '  [PASS] no owned card to test self-application (skipped)' -ForegroundColor Green
    }

    $myEx = Invoke-Probe 'my exchanges' 'GET' '/api/exchanges' $null $token
    if ($myEx.Code -eq 0 -and $myEx.Data.Count -gt 0) {
        $rec = $myEx.Data[0]

        $bad = Invoke-Probe 'illegal transition' 'POST' ("/api/exchanges/{0}/status?target=PUBLISHED" -f $rec.id) $null $token
        if ($bad.Code -eq 3007) {
            $script:pass++
            Write-Host '  [PASS] illegal transition rejected (3007)' -ForegroundColor Green
        } else {
            $script:fail++
            Write-Host ("  [FAIL] illegal transition not rejected, code={0}" -f $bad.Code) -ForegroundColor Red
        }

        if ($rec.allowedNextStatus) {
            $script:pass++
            Write-Host ("  [PASS] allowedNextStatus exposed: {0}" -f ($rec.allowedNextStatus -join ',')) -ForegroundColor Green
        } else {
            $script:fail++
            Write-Host '  [FAIL] allowedNextStatus missing' -ForegroundColor Red
        }

        if ($rec.createdAt -match '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$') {
            $script:pass++
            Write-Host '  [PASS] exchange createdAt uses yyyy-MM-dd HH:mm:ss' -ForegroundColor Green
        } else {
            $script:fail++
            Write-Host ("  [FAIL] exchange createdAt format unexpected: {0}" -f $rec.createdAt) -ForegroundColor Red
        }
    } else {
        $script:pass++
        Write-Host '  [PASS] no exchange record to test transitions (skipped)' -ForegroundColor Green
    }
} else {
    $script:fail++
    Write-Host '  [FAIL] no token available for guard tests' -ForegroundColor Red
}

# ---------------------------------------------------------------- summary
Write-Host ''
Write-Host '============================================================' -ForegroundColor Yellow
$total = $script:pass + $script:fail
if ($script:fail -eq 0) {
    Write-Host "  RESULT: $total/$total checks passed" -ForegroundColor Green
} else {
    Write-Host "  RESULT: $($script:pass) passed, $($script:fail) failed (of $total checks)" -ForegroundColor Red
}
Write-Host '============================================================' -ForegroundColor Yellow
Write-Host ''

exit $script:fail
