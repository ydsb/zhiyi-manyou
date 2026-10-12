param(
  [string]$BaseUrl = 'http://localhost:8080',
  [int[]]$Concurrency = @(50, 200, 500),
  [int]$RequestsPerWorker = 10,
  [string]$Path = '/api/health'
)

$ErrorActionPreference = 'Stop'
$uri = $BaseUrl.TrimEnd('/') + $Path
Write-Host "Baseline target: $uri"
foreach ($c in $Concurrency) {
  $jobs = 1..$c | ForEach-Object {
    Start-Job -ScriptBlock {
      param($target, $count)
      $elapsed = [System.Diagnostics.Stopwatch]::StartNew()
      $ok = 0; $failed = 0; $samples = New-Object System.Collections.Generic.List[long]
      1..$count | ForEach-Object {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        try { Invoke-WebRequest -UseBasicParsing -Uri $target -TimeoutSec 30 | Out-Null; $ok++ } catch { $failed++ }
        $sw.Stop(); $samples.Add($sw.ElapsedMilliseconds)
      }
      [pscustomobject]@{ Ok=$ok; Failed=$failed; Samples=$samples }
    } -ArgumentList $uri, $RequestsPerWorker
  }
  $results = $jobs | Wait-Job | Receive-Job
  $all = @($results | ForEach-Object { $_.Samples }) | Sort-Object
  $total = ($results | Measure-Object -Property Ok -Sum).Sum + ($results | Measure-Object -Property Failed -Sum).Sum
  $ok = ($results | Measure-Object -Property Ok -Sum).Sum
  $p = { param($q) if ($all.Count -eq 0) { 0 } else { $all[[Math]::Min($all.Count-1, [Math]::Floor(($all.Count-1)*$q))] } }
  [pscustomobject]@{ Concurrency=$c; Requests=$total; Errors=$total-$ok; P50ms=&$p .50; P95ms=&$p .95; P99ms=&$p .99 }
  $jobs | Remove-Job -Force
}
