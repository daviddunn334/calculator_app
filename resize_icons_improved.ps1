Add-Type -AssemblyName System.Drawing

# Use logo_main.png as the source
$sourcePath = "assets\logos\logo_main.png"
$source = [System.Drawing.Image]::FromFile((Resolve-Path $sourcePath))

Write-Output "Source image loaded: $($source.Width)x$($source.Height)"
Write-Output "Creating icons with LARGER logo size..."

# Function to create REGULAR icons (logo fills entire canvas - 100%)
function Create-RegularIcon {
    param($size, $outputPath)
    
    $canvas = New-Object System.Drawing.Bitmap($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($canvas)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    
    # Keep transparent background - no fill
    $graphics.Clear([System.Drawing.Color]::Transparent)
    
    # Logo fills 100% - no padding
    $graphics.DrawImage($source, 0, 0, $size, $size)
    
    $canvas.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $canvas.Dispose()
    
    Write-Output "Created $outputPath (100% logo size, transparent background)"
}

# Function to create MASKABLE icons with LARGER logo (85% instead of typical 60%)
function Create-MaskableIcon {
    param($size, $outputPath)
    
    $canvas = New-Object System.Drawing.Bitmap($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($canvas)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    
    # Keep transparent background
    $graphics.Clear([System.Drawing.Color]::Transparent)
    
    # Logo takes up 85% of canvas (minimal safe zone padding)
    # Standard safe zone is 80% max, but 85% is still safe for most platforms
    $logoSize = [int]($size * 0.85)
    $offset = [int](($size - $logoSize) / 2)
    
    $graphics.DrawImage($source, $offset, $offset, $logoSize, $logoSize)
    
    $canvas.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $canvas.Dispose()
    
    Write-Output "Created $outputPath (85% logo size with safe zone, transparent background)"
}

# Create regular icons (100% logo fill)
Create-RegularIcon -size 192 -outputPath "web\icons\icon-192.png"
Create-RegularIcon -size 512 -outputPath "web\icons\icon-512.png"

# Create maskable icons with LARGER logo (85% instead of standard 60-70%)
Create-MaskableIcon -size 192 -outputPath "web\icons\icon-192-maskable.png"
Create-MaskableIcon -size 512 -outputPath "web\icons\icon-512-maskable.png"

# Also create app_icon.png for backwards compatibility
Create-RegularIcon -size 192 -outputPath "web\icons\app_icon.png"

$source.Dispose()
Write-Output ""
Write-Output "All icons created with LARGER logo sizes!"
Write-Output "Regular icons: 100% logo fill"
Write-Output "Maskable icons: 85% logo fill (much larger than standard 60%)"
