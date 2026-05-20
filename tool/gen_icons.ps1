# gen_icons.ps1 - Generate per-density Android icon assets from source PNGs.
# Usage: pwsh tool/gen_icons.ps1
# Idempotent: re-running overwrites generated files. Originals (in assets/) are never modified.

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$src  = Join-Path $root 'assets/icons/custom/smritive-icon.png'
if (-not (Test-Path $src)) { throw "Source icon not found: $src" }

# Density → multiplier table (mdpi = 1x baseline)
$densities = @{
  'mdpi'    = 1.0
  'hdpi'    = 1.5
  'xhdpi'   = 2.0
  'xxhdpi'  = 3.0
  'xxxhdpi' = 4.0
}

# High-quality bilinear+bicubic resize that preserves alpha
function Resize-Png {
  param(
    [Parameter(Mandatory)] [string] $InPath,
    [Parameter(Mandatory)] [string] $OutPath,
    [Parameter(Mandatory)] [int] $Size,
    [double] $InsetRatio = 0.0,    # 0.0 = fill; 0.16 = 16% inset on each side
    [System.Drawing.Color] $Background = [System.Drawing.Color]::Transparent,
    [int] $CanvasSize = 0          # if >0, place icon centered on transparent canvas of this size
  )
  $canvas = if ($CanvasSize -gt 0) { $CanvasSize } else { $Size }
  $bmp = New-Object System.Drawing.Bitmap($canvas, $canvas, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  try {
    $g.Clear($Background)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality= [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $img = [System.Drawing.Image]::FromFile($InPath)
    try {
      $iconSize = [int]([Math]::Round($Size * (1.0 - 2.0 * $InsetRatio)))
      $offset = [int][Math]::Round(($canvas - $iconSize) / 2.0)
      $rect = New-Object System.Drawing.Rectangle($offset, $offset, $iconSize, $iconSize)
      $g.DrawImage($img, $rect)
    } finally { $img.Dispose() }
    New-Item -ItemType Directory -Force -Path (Split-Path $OutPath) | Out-Null
    $bmp.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
  } finally {
    $g.Dispose(); $bmp.Dispose()
  }
}

function Gen-IconSet {
  param(
    [Parameter(Mandatory)] [string] $FlavorRoot,   # android/app/src/<flavor>/res
    [Parameter(Mandatory)] [string] $SourceIcon,   # path to source PNG
    [string] $Tint = $null                         # optional: hex tint to apply (e.g. '#94A3B8' for free)
  )

  # If a tint is requested, pre-process the source by tinting (multiply with tint colour).
  $effectiveSrc = $SourceIcon
  if ($Tint) {
    $effectiveSrc = Join-Path $env:TEMP ("smritive-icon-tinted-" + [System.IO.Path]::GetRandomFileName() + '.png')
    $img = [System.Drawing.Image]::FromFile($SourceIcon)
    try {
      $bmp = New-Object System.Drawing.Bitmap($img.Width, $img.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
      $g = [System.Drawing.Graphics]::FromImage($bmp)
      try {
        $g.Clear([System.Drawing.Color]::Transparent)
        $cm = New-Object System.Drawing.Imaging.ColorMatrix
        $c = [System.Drawing.ColorTranslator]::FromHtml($Tint)
        # Multiply original RGB with tint while keeping alpha intact.
        $cm.Matrix00 = $c.R / 255.0; $cm.Matrix11 = $c.G / 255.0; $cm.Matrix22 = $c.B / 255.0; $cm.Matrix33 = 1.0; $cm.Matrix44 = 1.0
        $ia = New-Object System.Drawing.Imaging.ImageAttributes
        $ia.SetColorMatrix($cm)
        $rect = New-Object System.Drawing.Rectangle(0, 0, $img.Width, $img.Height)
        $g.DrawImage($img, $rect, 0, 0, $img.Width, $img.Height, [System.Drawing.GraphicsUnit]::Pixel, $ia)
      } finally { $g.Dispose() }
      $bmp.Save($effectiveSrc, [System.Drawing.Imaging.ImageFormat]::Png)
      $bmp.Dispose()
    } finally { $img.Dispose() }
  }

  foreach ($d in $densities.GetEnumerator()) {
    $density = $d.Key; $mult = $d.Value

    # 1. Legacy launcher icon (mipmap-Xdpi/ic_launcher.png) - 48dp baseline
    $sz = [int]([Math]::Round(48 * $mult))
    Resize-Png -InPath $effectiveSrc -OutPath (Join-Path $FlavorRoot ("mipmap-$density/ic_launcher.png")) -Size $sz

    # 2. Adaptive-icon foreground (drawable-Xdpi/ic_launcher_foreground.png) - 108dp canvas, 66dp safe zone => 19.4% inset on each side
    $sz = [int]([Math]::Round(108 * $mult))
    Resize-Png -InPath $effectiveSrc -OutPath (Join-Path $FlavorRoot ("drawable-$density/ic_launcher_foreground.png")) -Size $sz -InsetRatio 0.20

    # 3. Splash icon for legacy launch_background (drawable-Xdpi/splash_icon.png) - ~96dp icon centered
    $sz = [int]([Math]::Round(96 * $mult))
    Resize-Png -InPath $effectiveSrc -OutPath (Join-Path $FlavorRoot ("drawable-$density/splash_icon.png")) -Size $sz

    # 4. Android 12+ splash animated icon (drawable-Xdpi/android12_splash.png) - 288dp canvas, inner 192dp icon zone => 33.3% inset on each side
    $sz = [int]([Math]::Round(288 * $mult))
    Resize-Png -InPath $effectiveSrc -OutPath (Join-Path $FlavorRoot ("drawable-$density/android12_splash.png")) -Size $sz -InsetRatio 0.333
  }

  if ($Tint) { Remove-Item -Path $effectiveSrc -Force -ErrorAction SilentlyContinue }
}

Write-Host "Generating PAID flavor assets (full color)..." -ForegroundColor Cyan
Gen-IconSet -FlavorRoot (Join-Path $root 'android/app/src/paid/res') -SourceIcon $src

Write-Host "Generating FREE flavor assets (muted tint #94A3B8)..." -ForegroundColor Cyan
Gen-IconSet -FlavorRoot (Join-Path $root 'android/app/src/free/res') -SourceIcon $src -Tint '#94A3B8'

Write-Host "Done." -ForegroundColor Green
