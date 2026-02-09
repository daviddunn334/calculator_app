Add-Type -AssemblyName System.Drawing

$source = [System.Drawing.Image]::FromFile((Resolve-Path "assets\logos\logo_main.png"))
$canvas = New-Object System.Drawing.Bitmap(180, 180)
$graphics = [System.Drawing.Graphics]::FromImage($canvas)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

# Keep transparent background
$graphics.Clear([System.Drawing.Color]::Transparent)

# Logo at 85%
$logoSize = [int](180 * 0.85)
$offset = [int]((180 - $logoSize) / 2)
$graphics.DrawImage($source, $offset, $offset, $logoSize, $logoSize)

$canvas.Save("web\icons\apple-touch-icon.png", [System.Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose()
$canvas.Dispose()
$source.Dispose()

Write-Output "Created apple-touch-icon.png (180x180 with 85% logo for iOS)"
