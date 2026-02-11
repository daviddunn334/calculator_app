# Logo Replacement Guide

This app has been converted into a generic template called "NDT Tool-Kit". All company-specific branding has been removed and replaced with generic branding.

## Where to Replace Logos

To customize this app for a new company, replace the following logo files with your company's branding:

### Main Logo Files

1. **`assets/logos/logo_main.png`** (Currently shows "INTEGRITY SPECIALISTS" text logo)
   - Used on: Login screen, signup screen, loading screen
   - Recommended size: 300x300px or larger
   - Format: PNG with transparent background
   - This is the primary logo that appears most prominently

2. **`assets/logos/logo_square.png`** (Square version)
   - Used for: App icons and square contexts
   - Recommended size: 512x512px
   - Format: PNG with transparent background

3. **`web/icons/logo_main.png`** (Web version)
   - Copy of main logo for web loading screen
   - Should match `assets/logos/logo_main.png`

### App Icons (Multiple Sizes)

Replace these icon files in `web/icons/`:
- `icon-192.png` (192x192px)
- `icon-512.png` (512x512px)  
- `icon-192-maskable.png` (192x192px with safe area)
- `icon-512-maskable.png` (512x512px with safe area)
- `app_icon.png` (Application icon)
- `apple-touch-icon.png` (Apple devices)

### Favicon

- `web/favicon.png` - Browser tab icon (32x32px or 64x64px)

### Android Icons

Located in `android/app/src/main/res/`:
- `mipmap-hdpi/ic_launcher.png` (72x72px)
- `mipmap-mdpi/ic_launcher.png` (48x48px)
- `mipmap-xhdpi/ic_launcher.png` (96x96px)
- `mipmap-xxhdpi/ic_launcher.png` (144x144px)
- `mipmap-xxxhdpi/ic_launcher.png` (192x192px)

### iOS Icons

Located in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`:
- Multiple icon sizes as specified in `Contents.json`
- Sizes range from 20x20 to 1024x1024

## Text Branding References

All text references have been changed from "Integrity Specialists" to "NDT Tool-Kit". If you want to change the app name, update these files:

### App Name Configuration

1. **`lib/screens/login_screen.dart`** - Lines showing 'NDT Tool-Kit' title
2. **`lib/screens/signup_screen.dart`** - Same as above
3. **`lib/widgets/app_drawer.dart`** - App name in drawer header
4. **`lib/widgets/admin_drawer.dart`** - Admin panel header
5. **`lib/screens/main_screen.dart`** - Top right logo text
6. **`web/manifest.json`** - PWA name and short_name
7. **`web/index.html`** - Page title and meta tags
8. **`pubspec.yaml`** - App name (line 1)

### PDF Reports

The PDF report generation service has also been updated:
- **`lib/services/enhanced_pdf_service.dart`** - Company header in PDF reports

## Quick Text Replace

To change "NDT Tool-Kit" to your company name:

1. Use Find & Replace in your IDE
2. Find: `NDT Tool-Kit`
3. Replace with: `Your Company Name`
4. Also search for: `NDT\nTOOL-KIT` (for multi-line instances)

## Design Guidelines

When creating new logos:

1. **Primary Logo** - Should work on both light and dark backgrounds
2. **Square Icon** - Keep important elements in the center "safe area" (80% of canvas)
3. **Maskable Icons** - Keep all important content within the central 80% circle
4. **Color Scheme** - Update `lib/theme/app_theme.dart` to match your brand colors:
   - `primaryNavy` = Your primary color
   - `accentGold` = Your accent color

## Helper Scripts

Use the provided PowerShell scripts to generate icon sizes:

```powershell
# Resize a logo to multiple icon sizes
.\resize_icons_improved.ps1

# Create Apple icon set
.\create_apple_icon.ps1
```

## Testing

After replacing logos:

1. Run `flutter clean`
2. Run `flutter pub get`
3. Build and test on each platform:
   - `flutter run -d chrome` (Web)
   - `flutter run -d android` (Android)
   - `flutter run -d ios` (iOS)

4. Verify logos appear correctly on:
   - Login screen
   - App drawer
   - PDF reports  
   - Browser tabs
   - Installed PWA icon
   - Mobile app icons

## Notes

- All functionality remains intact - only branding has been changed
- The app theme uses generic professional colors (navy blue and gold)
- PDF reports use a generic "NDT Tool-Kit" header placeholder
- All features, calculators, and tools remain fully functional
