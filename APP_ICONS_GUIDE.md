# App Icons Generation Guide

## Overview
This guide explains how to generate proper app icons for Android, iOS, and Web platforms using your company logo.

## Current Status
✅ Logo files are ready in `assets/logos/logo_square.png`
✅ Flutter launcher icons package is configured in `pubspec.yaml`

## Generate App Icons Automatically

### Using flutter_launcher_icons Package

1. **Update pubspec.yaml** (if needed):
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/logos/logo_square.png"
  # Optional: for adaptive icons on Android
  adaptive_icon_background: "#1b325b"  # Navy Blue
  adaptive_icon_foreground: "assets/logos/logo_square.png"
```

2. **Run the icon generator**:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

This will automatically generate all required icon sizes for:
- **Android**: All densities (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- **iOS**: All required sizes in Assets.xcassets
- **Web**: favicon and web icons

## Manual Icon Sizes (if needed)

### Android (`android/app/src/main/res/`)
- `mipmap-mdpi/ic_launcher.png`: 48x48
- `mipmap-hdpi/ic_launcher.png`: 72x72
- `mipmap-xhdpi/ic_launcher.png`: 96x96
- `mipmap-xxhdpi/ic_launcher.png`: 144x144
- `mipmap-xxxhdpi/ic_launcher.png`: 192x192

### iOS (`ios/Runner/Assets.xcassets/AppIcon.appiconset/`)
Multiple sizes from 20x20 to 1024x1024 as specified in Contents.json

### Web (`web/icons/`)
- `icon-192.png`: 192x192
- `icon-512.png`: 512x512
- `icon-192-maskable.png`: 192x192 (with safe zone padding)
- `icon-512-maskable.png`: 512x512 (with safe zone padding)
- `favicon.png`: 32x32 or 16x16

## App Store Requirements

### Google Play Store
- **Feature Graphic**: 1024x500 (required)
- **Icon**: 512x512 (high-res)
- **Screenshots**: At least 2, up to 8 per device type
  - Phone: 320-3840px on long side
  - 7" Tablet: 600-7680px
  - 10" Tablet: 1200-7680px

### Apple App Store
- **App Icon**: 1024x1024 (required)
- **Screenshots**:
  - 6.5" display (iPhone): 1284x2778 or 2778x1284
  - 5.5" display (iPhone): 1242x2208 or 2208x1242
  - 12.9" display (iPad Pro): 2048x2732 or 2732x2048
  - At least 3 screenshots required, up to 10

## Notes
- Your logo (`logo_square.png`) should be at least 1024x1024 with transparent background
- For best results, use a PNG with transparency
- The square logo should work well at small sizes
- Consider adding padding if the logo has elements that touch the edges

## Testing Icons
After generating:
1. Run on Android emulator/device to verify
2. Run on iOS simulator/device to verify
3. Check web browser tab for favicon
4. Verify all sizes look good at different scales
