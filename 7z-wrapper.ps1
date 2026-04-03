param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"

if (-not $RemainingArgs -or $RemainingArgs.Count -eq 0) {
  Write-Error "Missing 7z arguments."
}

$joined = [string]::Join(" ", $RemainingArgs)
$archive = $null
$outdir = $null

if ($RemainingArgs.Count -ge 3 -and $RemainingArgs[0] -eq "x") {
  $archive = $RemainingArgs[1]
  if ($RemainingArgs[2].StartsWith("-o")) {
    $outdir = $RemainingArgs[2].Substring(2)
  }
}

if (-not $archive -or -not $outdir) {
  if ($joined -match '^x\s+(?<archive>.+?)\s+-o(?<out>.+)$') {
    $archive = $Matches.archive
    $outdir = $Matches.out
  }
}

if (-not $archive) {
  Write-Error "Missing archive path."
}

if (-not $outdir) {
  Write-Error "Missing output directory."
}

if (-not (Test-Path $outdir)) {
  New-Item -ItemType Directory -Path $outdir -Force | Out-Null
}

tar -xf $archive -C $outdir
exit $LASTEXITCODE