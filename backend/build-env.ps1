# =============================================================================
#  ZhiYi Manyou - build environment   [ASCII-only file, see NOTE below]
#
#  Usage:
#      . .\build-env.ps1      # dot-source, note the leading dot
#      zy-build               # package
#      zy-run                 # start backend
#      zy-test                # run smoke test
#
#  Notes:
#   1. The project requires JDK 17 (Spring Boot 3.x).
#   2. The local Maven repository points to G:\DEV\.m2repo inside the workspace,
#      to avoid writing to %USERPROFILE%\.m2 on restricted environments.
#
#  NOTE: this file is intentionally ASCII-only. Windows PowerShell 5.1 reads
#        .ps1 files as GBK on Chinese Windows when they have no UTF-8 BOM, and
#        multi-byte characters can shift the parser and produce bogus syntax
#        errors such as "Unexpected token ')'". Keep all .ps1 files ASCII-only.
# =============================================================================

# JDK 17 path. Override with the ZY_JAVA_HOME environment variable if yours differs.
# The project needs JDK 17 because Spring Boot 3.x requires Java 17+.
$jdkFromEnv = $env:ZY_JAVA_HOME
if ([string]::IsNullOrWhiteSpace($jdkFromEnv)) {
    # NOTE: this fallback points at the original developer's machine. Set
    # ZY_JAVA_HOME (or pass -JdkHome) to use your own JDK 17 installation.
    $jdkFromEnv = 'G:\DEV\jdk17'
    Write-Host "[WARN] ZY_JAVA_HOME not set, falling back to $jdkFromEnv" -ForegroundColor Yellow
}
$env:JAVA_HOME = $jdkFromEnv
$env:MAVEN_HOME = 'G:\DEV\IntelliJ IDEA 2026.2.1\plugins\maven-plugin\lib\maven3'
$env:MAVEN_OPTS = '-Dfile.encoding=UTF-8'
$env:Path = "$env:JAVA_HOME\bin;$env:MAVEN_HOME\bin;$env:Path"

# Local Maven repository. Override with ZY_MAVEN_REPO if you keep it elsewhere.
$repoFromEnv = $env:ZY_MAVEN_REPO
if ([string]::IsNullOrWhiteSpace($repoFromEnv)) { $repoFromEnv = Join-Path (Split-Path $PSScriptRoot -Parent) '.m2repo' }
$script:ZY_REPO = $repoFromEnv
# Project root is derived from this script's own location, so the repository
# works from any checkout path (no hard-coded absolute paths).
$script:ZY_ROOT = $PSScriptRoot
$script:ZY_MVN = "$env:MAVEN_HOME\bin\mvn.cmd"

function zy-mvn {
    <#
    .SYNOPSIS
        Run Maven with the project JDK and the workspace-local repository.
    .EXAMPLE
        zy-mvn clean package -DskipTests
    #>
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Args)
    & $script:ZY_MVN -f "$script:ZY_ROOT\pom.xml" "-Dmaven.repo.local=$script:ZY_REPO" @Args
}

function zy-build {
    <#
    .SYNOPSIS
        Package the project, skipping tests.
    #>
    zy-mvn clean package -DskipTests
}

function zy-run {
    <#
    .SYNOPSIS
        Start the backend service (default port 8080).
    #>
    Push-Location $script:ZY_ROOT
    try {
        & $script:ZY_MVN -f "$script:ZY_ROOT\pom.xml" "-Dmaven.repo.local=$script:ZY_REPO" -pl zy-server -am spring-boot:run
    } finally {
        Pop-Location
    }
}

function zy-test {
    <#
    .SYNOPSIS
        Run the backend smoke test against a running server.
    #>
    param([string]$BaseUrl = 'http://localhost:8080')
    & powershell -ExecutionPolicy Bypass -File "$script:ZY_ROOT\smoke-test.ps1" -BaseUrl $BaseUrl
}

Write-Host 'ZhiYi Manyou build environment ready' -ForegroundColor Green
Write-Host "  JAVA_HOME   = $env:JAVA_HOME" -ForegroundColor Gray
Write-Host "  Maven       = $script:ZY_MVN" -ForegroundColor Gray
Write-Host "  local repo  = $script:ZY_REPO" -ForegroundColor Gray
Write-Host "  project     = $script:ZY_ROOT" -ForegroundColor Gray
Write-Host '  commands    : zy-mvn / zy-build / zy-run / zy-test' -ForegroundColor Gray
