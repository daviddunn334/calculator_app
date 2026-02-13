# NDT-ToolKit Deployment Guide

## Overview

The NDT-ToolKit has a **two-page architecture**:
1. **Landing Page** (`index.html`) - Marketing/advertisement page with login button
2. **Flutter App** (`app.html`) - Full application accessible after clicking "Login / Sign Up"

## Why Custom Deployment Process?

Flutter's build process overwrites the `index.html` file with the compiled Flutter app. To maintain both the landing page and the app, we use a custom deployment script that:

1. Builds the Flutter web app
2. Backs up the compiled Flutter app as `app.html`
3. Replaces `index.html` with our custom landing page
4. Deploys everything to Firebase Hosting

## Deployment Methods

### Method 1: Automated Script (Recommended)

#### Windows:
```bash
deploy.bat
```

#### Linux/Mac:
```bash
chmod +x deploy.sh
./deploy.sh
```

The script will:
- Build the Flutter web app
- Set up the landing page
- Deploy to Firebase automatically
- Show you the live URLs

### Method 2: Manual Deployment

If you prefer to deploy manually:

```bash
# 1. Build Flutter app
flutter build web

# 2. Backup Flutter app
# Windows:
copy /Y "build\web\index.html" "build\web\app.html"
# Linux/Mac:
cp -f "build/web/index.html" "build/web/app.html"

# 3. Copy landing page
# Windows:
copy /Y "web\index.html" "build\web\index.html"
# Linux/Mac:
cp -f "web/index.html" "build/web/index.html"

# 4. Copy assets
# Windows:
if not exist "build\web\icons" mkdir "build\web\icons"
copy /Y "web\icons\logo_main.png" "build\web\icons\logo_main.png"
# Linux/Mac:
mkdir -p "build/web/icons"
cp -f "web/icons/logo_main.png" "build/web/icons/logo_main.png"

# 5. Deploy to Firebase
firebase deploy --only hosting
```

## Firebase Hosting Configuration

The `firebase.json` file has been configured with proper URL rewrites:

```json
"rewrites": [
  {
    "source": "/app",
    "destination": "/app.html"
  },
  {
    "source": "/app/**",
    "destination": "/app.html"
  },
  {
    "source": "**",
    "destination": "/index.html"
  }
]
```

This ensures:
- `https://ndt-toolkit.web.app/` → Landing page
- `https://ndt-toolkit.web.app/app` → Flutter application

## File Structure

```
web/
├── index.html          # Custom landing page (dark theme)
├── app.html            # Original Flutter app index (backup)
├── icons/
│   └── logo_main.png   # Logo assets
└── [other assets]

build/web/              # Generated after build
├── index.html          # Landing page (after deployment)
├── app.html            # Flutter app (after deployment)
├── flutter.js          # Flutter runtime
├── main.dart.js        # Compiled Flutter app
└── [Flutter assets]
```

## Troubleshooting

### Issue: Landing page not showing after deployment

**Solution**: Make sure you're using the deployment script, not just `flutter build web` followed by `firebase deploy`. The script properly sets up both pages.

### Issue: App not loading at /app route

**Solution**: Verify your `firebase.json` has the correct rewrites configuration (see above).

### Issue: Assets missing on landing page

**Solution**: The deployment script copies necessary assets. If assets are still missing, check that `web/icons/logo_main.png` exists.

### Issue: Old version showing after deployment

**Solution**: 
1. Hard refresh your browser (Ctrl+Shift+R or Cmd+Shift+R)
2. Clear browser cache
3. Check Firebase Hosting console for deployment status

## Version Bumping

**IMPORTANT**: Before deploying, always bump versions:

1. **`web/service-worker.js`**: Update `CACHE_VERSION`
2. **`pubspec.yaml`**: Increment version

```yaml
version: 1.0.X+Y
```

Format: `MAJOR.MINOR.PATCH+BUILD`
- MAJOR: Breaking changes
- MINOR: New features (use for most deployments)
- PATCH: Bug fixes
- BUILD: ALWAYS increment

⚠️ **NO VERSION BUMP = NO AUTO-UPDATES FOR USERS**

## Deployment Checklist

Before deploying:

- [ ] Test locally with `flutter run -d chrome`
- [ ] Bump version in `pubspec.yaml`
- [ ] Update `CACHE_VERSION` in `web/service-worker.js`
- [ ] Commit changes to git
- [ ] Run deployment script
- [ ] Verify landing page loads
- [ ] Verify app loads at /app route
- [ ] Test login/signup flow
- [ ] Check PWA install prompt works

## URLs After Deployment

### Production (ndt-toolkit branch)
- Landing: https://ndt-toolkit.web.app/
- App: https://ndt-toolkit.web.app/app

### Company Internal (main branch)
- Landing: https://integrity-tools.web.app/
- App: https://integrity-tools.web.app/app

## CI/CD Integration

If using GitHub Actions or other CI/CD:

```yaml
- name: Deploy NDT-ToolKit
  run: |
    flutter build web
    cp -f build/web/index.html build/web/app.html
    cp -f web/index.html build/web/index.html
    mkdir -p build/web/icons
    cp -f web/icons/logo_main.png build/web/icons/logo_main.png
    firebase deploy --only hosting --token ${{ secrets.FIREBASE_TOKEN }}
```

## Support

For deployment issues:
- Check Firebase Console: https://console.firebase.google.com/
- Review Firebase Hosting logs
- Contact: ndt-toolkit-support@gmail.com
