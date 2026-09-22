# =============================================================================
#  ZhiYi Manyou - ontology graph verification   [ASCII-only, see NOTE]
#
#  Verifies the claim "the skill graph is now a real graph AND it actually feeds
#  cross-disciplinary augmentation" -- not merely "the table has some rows".
#
#  Usage:
#     powershell -ExecutionPolicy Bypass -File .\scripts\verify-graph.ps1
#     powershell -ExecutionPolicy Bypass -File .\scripts\verify-graph.ps1 -Database zhiyi_manyou
#
#  Exit code: 0 = all checks passed, 1 = at least one failure.
#
#  NOTE 1: ASCII-only ON PURPOSE, including comments. Windows PowerShell 5.1
#          parses .ps1 files as GBK on Chinese Windows unless the file carries a
#          UTF-8 BOM, and a Chinese string can shift the parser into bogus
#          "Unexpected token" errors on unrelated lines. Keeping the script ASCII
#          removes the failure mode entirely -- and it is not hypothetical: this
#          exact script broke twice, because every re-edit dropped the BOM.
#          Chinese skill names live in graph-seed-pairs.txt (UTF-8) instead and
#          are read at runtime with -Encoding UTF8.
#
#  NOTE 2: PowerShell variable names are case-insensitive; do not use $home/$pid.
#
#  Precondition: 10-ontology-graph.sql has been applied to the database.
# =============================================================================

[CmdletBinding()]
param(
    [string]$Database  = 'zhiyi_manyou',
    [string]$DbHost    = 'localhost',
    [int]   $Port      = 3306,
    [string]$User      = 'root',
    [string]$MysqlHome = $env:ZHIYI_MYSQL_HOME,
    # Thresholds are explicit on purpose: a graph that silently decayed to 50
    # edges would still "pass" a naive "is the table non-empty" check.
    [int]   $MinEdges    = 400,
    [int]   $MinCrossPct = 25
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

$script:pass = 0
$script:fail = 0

function Write-Head ([string]$m) {
    Write-Host ''
    Write-Host ('=' * 70) -ForegroundColor Yellow
    Write-Host "  $m" -ForegroundColor Yellow
    Write-Host ('=' * 70) -ForegroundColor Yellow
}
function Check ([string]$desc, [bool]$ok, [string]$detail) {
    if ($ok) {
        $script:pass++
        Write-Host ("  [PASS] {0,-52} {1}" -f $desc, $detail) -ForegroundColor Green
    } else {
        $script:fail++
        Write-Host ("  [FAIL] {0,-52} {1}" -f $desc, $detail) -ForegroundColor Red
    }
}

# ---------------------------------------------------------------------------
# locate mysql.exe
# ---------------------------------------------------------------------------
function Resolve-Mysql {
    if (-not [string]::IsNullOrWhiteSpace($MysqlHome)) {
        $p = Join-Path $MysqlHome 'bin\mysql.exe'
        if (Test-Path -LiteralPath $p) { return $p }
    }
    $c = Get-Command 'mysql.exe' -ErrorAction SilentlyContinue
    if ($c) { return $c.Source }
    foreach ($r in @('C:\Program Files\MySQL', 'G:\DEV\mysql', 'D:\DEV\mysql', 'C:\mysql')) {
        if (-not (Test-Path -LiteralPath $r)) { continue }
        $hit = Get-ChildItem -LiteralPath $r -Recurse -Filter 'mysql.exe' -ErrorAction SilentlyContinue |
               Select-Object -First 1
        if ($hit) { return $hit.FullName }
    }
    return $null
}

$mysql = Resolve-Mysql
if (-not $mysql) { Write-Host '[x] mysql.exe not found; set ZHIYI_MYSQL_HOME' -ForegroundColor Red; exit 1 }

if ($env:ZHIYI_DB_PASSWORD) {
    $env:MYSQL_PWD = $env:ZHIYI_DB_PASSWORD
} elseif (-not $env:MYSQL_PWD) {
    Write-Host '[x] set ZHIYI_DB_PASSWORD (or MYSQL_PWD) first' -ForegroundColor Red
    exit 1
}

# First row, tab separated, or $null when the query returns nothing.
# @() matters: under Set-StrictMode a single result is not an array and .Count throws.
function Sql-Scalar ([string]$sql) {
    $rows = @(& $mysql --default-character-set=utf8mb4 -h "$DbHost" -P "$Port" -u "$User" -N -e $sql 2>$null)
    if ($rows.Count -eq 0) { return $null }
    return ([string]$rows[0]).Trim()
}

# Builds a SQL string literal. Seed names are Chinese; never interpolate them raw.
function Sql-Str ([string]$s) {
    return "'" + $s.Replace('\', '\\').Replace("'", "''") + "'"
}

Write-Head 'ZhiYi Manyou - ontology graph verification'

# ---------------------------------------------------------------------------
# 1. the graph has substance
# ---------------------------------------------------------------------------
$edges = [int](Sql-Scalar "SELECT COUNT(*) FROM ``$Database``.zy_skill_ontology")
Check 'total edges' ($edges -ge $MinEdges) "edges=$edges (threshold $MinEdges)"

$types = [int](Sql-Scalar "SELECT COUNT(DISTINCT relation_type) FROM ``$Database``.zy_skill_ontology")
Check 'all three relation types present' ($types -eq 3) "types=$types"

# COMPLEMENT is the only type augment() reads. If it is empty the graph is
# decorative no matter how many PREREQUISITE edges exist.
$comp = [int](Sql-Scalar "SELECT COUNT(*) FROM ``$Database``.zy_skill_ontology WHERE relation_type='COMPLEMENT'")
Check 'COMPLEMENT edges (feeds augmentation)' ($comp -ge 200) "complement=$comp"

# A directed prerequisite is the whole point of PREREQUISITE; undirected ones
# would be a modelling bug that silently disables learning-path advice.
$pre = [int](Sql-Scalar "SELECT COUNT(*) FROM ``$Database``.zy_skill_ontology WHERE relation_type='PREREQUISITE'")
$preDir = [int](Sql-Scalar "SELECT COUNT(*) FROM ``$Database``.zy_skill_ontology WHERE relation_type='PREREQUISITE' AND directed=1")
Check 'PREREQUISITE edges are directed' (($pre -gt 0) -and ($preDir -eq $pre)) "directed=$preDir/$pre"

# COMPLEMENT is shown to users as an undirected relation, so store it as one.
$compUndir = [int](Sql-Scalar "SELECT COUNT(*) FROM ``$Database``.zy_skill_ontology WHERE relation_type='COMPLEMENT' AND directed=0")
Check 'COMPLEMENT edges are undirected' ($compUndir -eq $comp) "undirected=$compUndir/$comp"

# ---------------------------------------------------------------------------
# 2. cross-discipline share -- the actual product claim
# ---------------------------------------------------------------------------
$crossPct = [double](Sql-Scalar ("SELECT ROUND(100.0 * SUM(CASE WHEN a.category_l1 <> b.category_l1 THEN 1 ELSE 0 END) / COUNT(*), 1) " +
    "FROM ``$Database``.zy_skill_ontology o " +
    "JOIN ``$Database``.zy_skill a ON a.id = o.src_skill_id " +
    "JOIN ``$Database``.zy_skill b ON b.id = o.dst_skill_id"))
Check 'cross-category edge share' ($crossPct -ge $MinCrossPct) "$crossPct% (threshold $MinCrossPct%)"

$total = [int](Sql-Scalar "SELECT COUNT(*) FROM ``$Database``.zy_skill WHERE status = 1")
$isolated = [int](Sql-Scalar ("SELECT COUNT(*) FROM ``$Database``.zy_skill s WHERE s.status = 1 " +
    "AND NOT EXISTS (SELECT 1 FROM ``$Database``.zy_skill_ontology o " +
    "WHERE o.src_skill_id = s.id OR o.dst_skill_id = s.id)"))
$connected = $total - $isolated
# Not every skill needs a neighbour -- niche labels legitimately have none --
# but a majority should be reachable, otherwise the graph is a set of islands.
Check 'connected skills are the majority' (($connected * 2) -gt $total) "connected=$connected/$total"

# ---------------------------------------------------------------------------
# 3. no dangling edges
#
# zy_skill_ontology has NO foreign keys, so an edge pointing at a nonexistent
# skill is accepted silently and simply never matches at query time. That is the
# failure the generator's name validation exists to prevent; re-check it here
# against real data rather than trusting the generator.
# ---------------------------------------------------------------------------
$dangling = [int](Sql-Scalar ("SELECT COUNT(*) FROM ``$Database``.zy_skill_ontology o " +
    "LEFT JOIN ``$Database``.zy_skill a ON a.id = o.src_skill_id " +
    "LEFT JOIN ``$Database``.zy_skill b ON b.id = o.dst_skill_id " +
    "WHERE a.id IS NULL OR b.id IS NULL"))
Check 'no dangling edges' ($dangling -eq 0) "dangling=$dangling"

$selfLoops = [int](Sql-Scalar "SELECT COUNT(*) FROM ``$Database``.zy_skill_ontology WHERE src_skill_id = dst_skill_id")
Check 'no self loops' ($selfLoops -eq 0) "self_loops=$selfLoops"

# ---------------------------------------------------------------------------
# 4. augmentation actually has fuel
#
# The real question is not "how many edges" but "does a realistic seed reach a
# cross-disciplinary partner". The pairs come from a data file so that this
# script can stay ASCII-only (see NOTE 1).
# ---------------------------------------------------------------------------
Write-Host ''
Write-Host '  -- augmentation reachability (COMPLEMENT only) --' -ForegroundColor Cyan

$pairFile = Join-Path $PSScriptRoot 'graph-seed-pairs.txt'
if (-not (Test-Path -LiteralPath $pairFile)) {
    Check 'seed pair data file present' $false $pairFile
} else {
    $pairLines = @(Get-Content -LiteralPath $pairFile -Encoding UTF8 |
                   Where-Object { $_.Trim() -ne '' -and -not $_.TrimStart().StartsWith('#') })
    Check 'seed pair data file present' ($pairLines.Count -ge 3) "pairs=$($pairLines.Count)"
    foreach ($line in $pairLines) {
        $parts = $line -split '\|'
        if ($parts.Count -lt 2) { continue }
        $s = $parts[0].Trim()
        $d = $parts[1].Trim()
        $q = ("SELECT COUNT(*) FROM ``$Database``.zy_skill_ontology o " +
              "JOIN ``$Database``.zy_skill a ON a.id = o.src_skill_id " +
              "JOIN ``$Database``.zy_skill b ON b.id = o.dst_skill_id " +
              "WHERE o.relation_type = 'COMPLEMENT' AND " +
              "((a.name = $(Sql-Str $s) AND b.name = $(Sql-Str $d)) OR " +
              " (a.name = $(Sql-Str $d) AND b.name = $(Sql-Str $s)))")
        $hit = [int](Sql-Scalar $q)
        Check "reachable: $s <-> $d" ($hit -ge 1) "edges=$hit"
    }
}

# A seed with a single neighbour is nearly as useless as no seed at all.
# NOTE: COMPLEMENT is undirected and the generator stores each pair exactly once,
# in whichever order the name sort produced. Counting only src_skill_id measures
# half of every neighbourhood -- the first version of this check did exactly
# that and reported max degree 4 while the real undirected hub had 13.
$maxDeg = [int](Sql-Scalar ("SELECT MAX(c) FROM (SELECT skill_id, COUNT(*) AS c FROM ( " +
    "SELECT src_skill_id AS skill_id FROM ``$Database``.zy_skill_ontology WHERE relation_type='COMPLEMENT' " +
    "UNION ALL " +
    "SELECT dst_skill_id AS skill_id FROM ``$Database``.zy_skill_ontology WHERE relation_type='COMPLEMENT' " +
    ") e GROUP BY skill_id) t"))
Check 'hub skill has rich neighbourhood' ($maxDeg -ge 5) "max_degree=$maxDeg"

Write-Host ''
Write-Host ('=' * 70)
if ($script:fail -eq 0) {
    Write-Host ("  RESULT: all {0} checks passed" -f $script:pass) -ForegroundColor Green
} else {
    Write-Host ("  RESULT: {0} passed, {1} FAILED" -f $script:pass, $script:fail) -ForegroundColor Red
}
Write-Host ('=' * 70)
Write-Host ''
exit ([int]($script:fail -gt 0))
