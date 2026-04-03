param(
  [string]$SourcePath = "../intelliexplorericon.png",
  [string]$BrandName = "IntelliExplorer"
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$resolvedSourcePath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot $SourcePath))

if (-not (Test-Path $resolvedSourcePath)) {
  throw "Source icon not found: $resolvedSourcePath"
}

$pngFormat = [System.Drawing.Imaging.ImageFormat]::Png
$sourceBytes = [System.IO.File]::ReadAllBytes($resolvedSourcePath)
$sourceBase64 = [Convert]::ToBase64String($sourceBytes)
$sourceImage = [System.Drawing.Image]::FromFile($resolvedSourcePath)

function Save-ResizedPng {
  param(
    [System.Drawing.Image]$Image,
    [string]$Destination,
    [int]$Width,
    [int]$Height
  )

  $bitmap = New-Object System.Drawing.Bitmap $Width, $Height, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $bitmap.SetResolution(96, 96)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.Clear([System.Drawing.Color]::Transparent)
  $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $graphics.DrawImage($Image, 0, 0, $Width, $Height)
  $bitmap.Save($Destination, $pngFormat)
  $graphics.Dispose()
  $bitmap.Dispose()
}

function New-PngBytes {
  param(
    [System.Drawing.Image]$Image,
    [int]$Size
  )

  $bitmap = New-Object System.Drawing.Bitmap $Size, $Size, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $bitmap.SetResolution(96, 96)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $memory = New-Object System.IO.MemoryStream
  $graphics.Clear([System.Drawing.Color]::Transparent)
  $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $graphics.DrawImage($Image, 0, 0, $Size, $Size)
  $bitmap.Save($memory, $pngFormat)
  $bytes = $memory.ToArray()
  $memory.Dispose()
  $graphics.Dispose()
  $bitmap.Dispose()
  return $bytes
}

function Save-IcoFromPng {
  param(
    [byte[]]$PngBytes,
    [string]$Destination,
    [int]$Size
  )

  $stream = [System.IO.File]::Open($Destination, [System.IO.FileMode]::Create)
  $writer = New-Object System.IO.BinaryWriter($stream)
  $dimensionByte = if ($Size -ge 256) { 0 } else { [byte]$Size }

  $writer.Write([UInt16]0)
  $writer.Write([UInt16]1)
  $writer.Write([UInt16]1)
  $writer.Write($dimensionByte)
  $writer.Write($dimensionByte)
  $writer.Write([byte]0)
  $writer.Write([byte]0)
  $writer.Write([UInt16]1)
  $writer.Write([UInt16]32)
  $writer.Write([UInt32]$PngBytes.Length)
  $writer.Write([UInt32]22)
  $writer.Write($PngBytes)
  $writer.Dispose()
  $stream.Dispose()
}

function Write-Utf8File {
  param(
    [string]$Path,
    [string]$Content
  )

  [System.IO.File]::WriteAllText($Path, $Content, [System.Text.UTF8Encoding]::new($false))
}

$pngTargets = @(
  @{ Path = "configs/branding/release/logo.png"; Width = 1024; Height = 1024 },
  @{ Path = "configs/branding/release/logo16.png"; Width = 16; Height = 16 },
  @{ Path = "configs/branding/release/logo22.png"; Width = 22; Height = 22 },
  @{ Path = "configs/branding/release/logo24.png"; Width = 24; Height = 24 },
  @{ Path = "configs/branding/release/logo32.png"; Width = 32; Height = 32 },
  @{ Path = "configs/branding/release/logo48.png"; Width = 48; Height = 48 },
  @{ Path = "configs/branding/release/logo64.png"; Width = 64; Height = 64 },
  @{ Path = "configs/branding/release/logo128.png"; Width = 128; Height = 128 },
  @{ Path = "configs/branding/release/logo256.png"; Width = 256; Height = 256 },
  @{ Path = "configs/branding/release/logo512.png"; Width = 512; Height = 512 },
  @{ Path = "configs/branding/release/logo1024.png"; Width = 1024; Height = 1024 },
  @{ Path = "configs/branding/release/logo-mac.png"; Width = 1024; Height = 1024 },
  @{ Path = "configs/branding/release/PrivateBrowsing_70.png"; Width = 126; Height = 126 },
  @{ Path = "configs/branding/release/PrivateBrowsing_150.png"; Width = 270; Height = 270 },
  @{ Path = "configs/branding/release/VisualElements_70.png"; Width = 1042; Height = 1046 },
  @{ Path = "configs/branding/release/VisualElements_150.png"; Width = 1042; Height = 1046 },
  @{ Path = "configs/branding/release/content/about-logo.png"; Width = 512; Height = 512 },
  @{ Path = "configs/branding/release/content/about-logo@2x.png"; Width = 1024; Height = 1024 },
  @{ Path = "configs/branding/release/content/about-logo-private.png"; Width = 192; Height = 192 },
  @{ Path = "configs/branding/release/content/about-logo-private@2x.png"; Width = 384; Height = 384 },
  @{ Path = "configs/branding/twilight/logo.png"; Width = 1024; Height = 1024 },
  @{ Path = "configs/branding/twilight/logo16.png"; Width = 16; Height = 16 },
  @{ Path = "configs/branding/twilight/logo22.png"; Width = 22; Height = 22 },
  @{ Path = "configs/branding/twilight/logo24.png"; Width = 24; Height = 24 },
  @{ Path = "configs/branding/twilight/logo32.png"; Width = 32; Height = 32 },
  @{ Path = "configs/branding/twilight/logo48.png"; Width = 48; Height = 48 },
  @{ Path = "configs/branding/twilight/logo64.png"; Width = 64; Height = 64 },
  @{ Path = "configs/branding/twilight/logo128.png"; Width = 128; Height = 128 },
  @{ Path = "configs/branding/twilight/logo256.png"; Width = 256; Height = 256 },
  @{ Path = "configs/branding/twilight/logo512.png"; Width = 512; Height = 512 },
  @{ Path = "configs/branding/twilight/logo1024.png"; Width = 1024; Height = 1024 },
  @{ Path = "configs/branding/twilight/logo-mac.png"; Width = 1024; Height = 1024 },
  @{ Path = "configs/branding/twilight/PrivateBrowsing_70.png"; Width = 126; Height = 126 },
  @{ Path = "configs/branding/twilight/PrivateBrowsing_150.png"; Width = 270; Height = 270 },
  @{ Path = "configs/branding/twilight/VisualElements_70.png"; Width = 1042; Height = 1046 },
  @{ Path = "configs/branding/twilight/VisualElements_150.png"; Width = 1042; Height = 1046 },
  @{ Path = "configs/branding/twilight/content/about-logo.png"; Width = 512; Height = 512 },
  @{ Path = "configs/branding/twilight/content/about-logo@2x.png"; Width = 1024; Height = 1024 },
  @{ Path = "configs/branding/twilight/content/about-logo-private.png"; Width = 192; Height = 192 },
  @{ Path = "configs/branding/twilight/content/about-logo-private@2x.png"; Width = 384; Height = 384 }
)

foreach ($target in $pngTargets) {
  $destination = Join-Path $repoRoot $target.Path
  Save-ResizedPng -Image $sourceImage -Destination $destination -Width $target.Width -Height $target.Height
}

$png256 = New-PngBytes -Image $sourceImage -Size 256
$png64 = New-PngBytes -Image $sourceImage -Size 64
$png32 = New-PngBytes -Image $sourceImage -Size 32

$icoTargets = @(
  @{ Path = "configs/branding/release/document.ico"; Bytes = $png32; Size = 32 },
  @{ Path = "configs/branding/release/document_pdf.ico"; Bytes = $png32; Size = 32 },
  @{ Path = "configs/branding/release/firefox.ico"; Bytes = $png256; Size = 256 },
  @{ Path = "configs/branding/release/firefox64.ico"; Bytes = $png64; Size = 64 },
  @{ Path = "configs/branding/release/pbmode.ico"; Bytes = $png256; Size = 256 },
  @{ Path = "configs/branding/twilight/document.ico"; Bytes = $png32; Size = 32 },
  @{ Path = "configs/branding/twilight/document_pdf.ico"; Bytes = $png32; Size = 32 },
  @{ Path = "configs/branding/twilight/firefox.ico"; Bytes = $png256; Size = 256 },
  @{ Path = "configs/branding/twilight/firefox64.ico"; Bytes = $png64; Size = 64 },
  @{ Path = "configs/branding/twilight/pbmode.ico"; Bytes = $png256; Size = 256 }
)

foreach ($target in $icoTargets) {
  $destination = Join-Path $repoRoot $target.Path
  Save-IcoFromPng -PngBytes $target.Bytes -Destination $destination -Size $target.Size
}

$iconSvg = @"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
  <image href="data:image/png;base64,$sourceBase64" width="1024" height="1024" preserveAspectRatio="xMidYMid meet"/>
</svg>
"@

$wordmarkSvg = @"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 420 96" width="420" height="96">
  <rect width="420" height="96" fill="none"/>
  <image href="data:image/png;base64,$sourceBase64" x="0" y="8" width="80" height="80" preserveAspectRatio="xMidYMid meet"/>
  <text x="96" y="60" fill="#111111" font-family="Segoe UI, Arial, sans-serif" font-size="38" font-weight="700">$BrandName</text>
</svg>
"@

$docWordmarkSvg = @"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 96" width="320" height="96">
  <rect width="320" height="96" fill="none"/>
  <image href="data:image/png;base64,$sourceBase64" x="0" y="8" width="80" height="80" preserveAspectRatio="xMidYMid meet"/>
  <text x="96" y="60" fill="#1f1f1f" font-family="Segoe UI, Arial, sans-serif" font-size="34" font-weight="700">$BrandName</text>
</svg>
"@

$svgTargets = @(
  @{ Path = "configs/branding/release/content/about-logo.svg"; Content = $iconSvg },
  @{ Path = "configs/branding/release/content/about-logo-private.svg"; Content = $iconSvg },
  @{ Path = "configs/branding/release/content/about-wordmark.svg"; Content = $wordmarkSvg },
  @{ Path = "configs/branding/release/content/firefox-wordmark.svg"; Content = $wordmarkSvg },
  @{ Path = "configs/branding/release/MacOSInstaller.svg"; Content = $iconSvg },
  @{ Path = "configs/branding/twilight/content/about-logo.svg"; Content = $iconSvg },
  @{ Path = "configs/branding/twilight/content/about-logo-private.svg"; Content = $iconSvg },
  @{ Path = "configs/branding/twilight/content/about-wordmark.svg"; Content = $wordmarkSvg },
  @{ Path = "configs/branding/twilight/content/firefox-wordmark.svg"; Content = $wordmarkSvg },
  @{ Path = "configs/branding/twilight/MacOSInstaller.svg"; Content = $iconSvg },
  @{ Path = "docs/assets/zen-black.svg"; Content = $iconSvg },
  @{ Path = "docs/assets/zen-dark.svg"; Content = $iconSvg },
  @{ Path = "docs/assets/zen-light.svg"; Content = $iconSvg },
  @{ Path = "docs/assets/zen-browser.svg"; Content = $docWordmarkSvg }
)

foreach ($target in $svgTargets) {
  $destination = Join-Path $repoRoot $target.Path
  Write-Utf8File -Path $destination -Content $target.Content
}

$sourceImage.Dispose()
Write-Output "Branding assets regenerated from $resolvedSourcePath"