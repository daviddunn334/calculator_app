Add-Type -AssemblyName System.Drawing

# Use logo_main.png instead - the circular logo without extra padding
$sourcePath = "assets\logos\logo_main.png"
$source = [System.Drawing.Image]::FromFile((Resolve-Path $sourcePath))

Write-Output "Source image loaded: $($source.Width)x$($source.Height)"
Write-Output "Creating icons with logo filling entire canvas (no scaling down)..."

# Function to create icon with logo filling the entire space
function Create-IconFullSize {
    param($size, $outputPath)
    
    # Create canvas
    $canvas = New-Object System.Drawing.Bitmap($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($canvas)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    
    # Fill entire canvas with logo - no padding!
    $graphics.DrawImage($source, 0, 0, $size, $size)
    
    $canvas.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $canvas.Dispose()
    
    Write-Output "Created $outputPath (logo fills entire ${size}x${size} canvas)"
}

# Create all icons with logo filling entire space
Create-IconFullSize -size 180 -outputPath "web\icons\Icon-180.png"
Create-IconFullSize -size 192 -outputPath "web\icons\Icon-192.png"
Create-IconFullSize -size 512 -outputPath "web\icons\Icon-512.png"
Create-IconFullSize -size 192 -outputPath "web\icons\icon-192-maskable.png"
Create-IconFullSize -size 512 -outputPath "web\icons\icon-512-maskable.png"

$source.Dispose()
Write-Output ""
Write-Output "All icons created with logo filling entire canvas!"
