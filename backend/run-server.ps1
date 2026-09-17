# =============================================================================
#  ZhiYi Manyou - backend launcher   [ASCII-only file, see NOTE below]
#
#  Usage:
#      powershell -ExecutionPolicy Bypass -File backend\run-server.ps1
#      powershell -ExecutionPolicy Bypass -File backend\run-server.ps1 -Port 9090
#      powershell -ExecutionPolicy Bypass -File backend\run-server.ps1 -Rebuild
#
#  Preconditions:
#      1. MySQL is running and sql\01-schema.sql has been imported (database zhiyi_manyou)
#      2. zy-server\target\zy-server.jar exists, or pass -Rebuild to build it first
#
#  NOTE: this file is intentionally ASCII-only. Windows PowerShell 5.1 reads
#        .ps1 files as GBK on Chinese Windows when they have no UTF-8 BOM, and
#        multi-byte characters can shift the parser and produce bogus syntax
#        errors such as "Unexpected token ')'". Keep all .ps1 files ASCII-only.
# =============================================================================

param(
    [int]$Port = 8080,
    [switch]$Rebuild,
    [string]$JdkHome = $(if ($env:ZY_JAVA_HOME) { $env:ZY_JAVA_HOME } else { 'G:\DEV\jdk17' }),
    [string]$MavenHome = $(if ($env:ZY_MAVEN_HOME) { $env:ZY_MAVEN_HOME } else { 'G:\DEV\IntelliJ IDEA 2026.2.1\plugins\maven-plugin\lib\maven3' }),
    # Database credentials are only used for the pre-flight check that the schema
    # has been imported. They are never written to disk in this repository.
    [string]$DbUser = $(if ($env:ZY_DB_USER) { $env:ZY_DB_USER } else { 'root' }),
    [string]$DbPassword = $env:ZY_DB_PASSWORD,
    [string]$MavenRepo = $(if ($env:ZY_MAVEN_REPO) { $env:ZY_MAVEN_REPO } else { Join-Path (Split-Path $PSScriptRoot -Parent) '.m2repo' })
)

$ErrorActionPreference = 'Stop'

$root = $PSScriptRoot
$jar = Join-Path $root 'zy-server\target\zy-server.jar'

# ---------------------------------------------------------------------------
# 1. Environment checks
# ---------------------------------------------------------------------------
$java = Join-Path $JdkHome 'bin\java.exe'
if (-not (Test-Path $java)) {
    throw "JDK not found: $java.  Set ZY_JAVA_HOME or pass -JdkHome (JDK 17 required for Spring Boot 3.x)."
}

if ($Rebuild -or -not (Test-Path $jar)) {
    $mvn = Join-Path $MavenHome 'bin\mvn.cmd'
    if (-not (Test-Path $mvn)) {
        throw "Maven not found: $mvn  (use -MavenHome, or build the jar manually)"
    }
    Write-Host '[BUILD] packaging zy-server ...' -ForegroundColor Cyan
    $env:JAVA_HOME = $JdkHome
    & $mvn -B -f (Join-Path $root 'pom.xml') "-Dmaven.repo.local=$MavenRepo" clean package -DskipTests
    if ($LASTEXITCODE -ne 0) { throw 'Build failed, see Maven output above.' }
}

# ---------------------------------------------------------------------------
# 2. Database pre-check (advisory only - never blocks startup)
# ---------------------------------------------------------------------------
# The mysql client always writes "Using a password on the command line is
# insecure" to stderr. With $ErrorActionPreference = 'Stop' that native stderr
# output would be turned into a terminating error, so the whole probe runs
# inside a try/catch that swallows everything.
$mysql = if ($env:ZY_MYSQL_CLIENT) { $env:ZY_MYSQL_CLIENT } else { 'mysql.exe' }
$mysqlFound = (Test-Path $mysql) -or [bool](Get-Command $mysql -ErrorAction SilentlyContinue)
if (-not $mysqlFound) {
    Write-Host "[CHECK] mysql client not found, skipping database pre-check." -ForegroundColor DarkGray
} elseif ([string]::IsNullOrEmpty($DbPassword)) {
    Write-Host "[CHECK] ZY_DB_PASSWORD not set, skipping database pre-check." -ForegroundColor DarkGray
} else {
    $probe = & $mysql "-u$DbUser" "-p$DbPassword" -N -B -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='zhiyi_manyou';" 2>&1 |
             Where-Object { $_ -notmatch 'password on the command line' } | Select-Object -First 1
    if ($probe -match '^\d+$' -and [int]$probe -gt 0) {
        Write-Host "[CHECK] MySQL ok, database zhiyi_manyou has $probe tables" -ForegroundColor Green
    } else {
        Write-Warning "database zhiyi_manyou not found or not reachable. Import sql/01-schema.sql first (see README)."
    }
}
Write-Host "[CHECK] MySQL ok, database zhiyi_manyou has $probe tables" -ForegroundColor Green
        } else {
            Write-Warning "database zhiyi_manyou not found. Run: mysql -uroot -p < `"$root\sql\01-schema.sql`""
        }
    } catch {
        Write-Warning "database pre-check skipped: $($_.Exception.Message)"
    }
} else {
    Write-Warning "mysql client not found ($mysql), skipping database pre-check."
}

# ---------------------------------------------------------------------------
# 3. Launch
# ---------------------------------------------------------------------------
# IMPORTANT: do NOT put -Dfile.encoding into $env:JAVA_TOOL_OPTIONS.
#            PowerShell mangles the dot in -D arguments, producing
#            "ClassNotFoundException: /encoding=UTF-8". Use a splatted array.
$javaArgs = @(
    '-Dfile.encoding=UTF-8',
    '-Duser.timezone=Asia/Shanghai',
    '-jar', $jar,
    "--server.port=$Port"
)

Write-Host ''
Write-Host '============================================================' -ForegroundColor Yellow
Write-Host '  ZhiYi Manyou - Cross-disciplinary Skill Exchange Platform' -ForegroundColor Yellow
Write-Host '  Backend service' -ForegroundColor Yellow
Write-Host '============================================================' -ForegroundColor Yellow
Write-Host "  API base   : http://localhost:$Port/api" -ForegroundColor Gray
Write-Host "  Health     : http://localhost:$Port/api/health" -ForegroundColor Gray
Write-Host "  Actuator   : http://localhost:$Port/actuator/health" -ForegroundColor Gray
Write-Host "  Test users : admin / 123456   or   2024117420 / 123456" -ForegroundColor Gray
Write-Host '  Stop       : press Ctrl+C in this window' -ForegroundColor Gray
Write-Host '------------------------------------------------------------' -ForegroundColor Yellow
Write-Host ''

& $java @javaArgs
