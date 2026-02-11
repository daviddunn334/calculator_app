# PWA OPTIMIZATION & INSTALL PROMPT - IMPLEMENTATION GUIDE

## Overview
This document outlines the PWA (Progressive Web App) optimizations implemented for Integrity Tools, including install prompt, enhanced caching, and controlled update deployment.

**Version:** 1.0.1+2  
**Implementation Date:** February 10, 2026  
**Status:** ✅ Complete

---

## 📦 What Was Implemented

### 1. **Install Prompt System** (`web/install-prompt.js`)
- Captures `beforeinstallprompt` event from browser
- Shows custom install banner on **first visit**
- Tracks user actions via localStorage
- Beautiful branded UI with company colors
- Integrated with Firebase Analytics for tracking
- Shows after 2-second delay on eligible visits

**Features:**
- Visit counting (shows on 1st visit)
- Dismissible (won't show again if dismissed)
- Auto-detects if app is already installed
- Tracks installation success
- Analytics events: `pwa_install_prompt_shown`, `pwa_install_prompt_action`, `pwa_installed`, `pwa_launched`

### 2. **Enhanced Manifest** (`web/manifest.json`)
**Changes Made:**
- `start_url`: Changed from `"."` to `"/"`
- `orientation`: Changed from `"portrait-primary"` to `"any"`
- Added 4 shortcuts:
  - Tools (/?screen=tools)
  - Reports (/?screen=reports)
  - Knowledge Base (/?screen=knowledge)
  - Company Directory (/?screen=directory)

### 3. **Advanced Service Worker** (`web/service-worker.js`)
**Version:** v1.0.1

**Caching Strategies:**
- **Cache-First**: Static assets (JS, CSS, fonts, images) - Fast, reliable
- **Network-First**: API calls and Firestore - Fresh data when online
- **Stale-While-Revalidate**: HTML content - Instant load, updates in background

**Features:**
- Version-based cache names (`integrity-tools-v1.0.1`)
- Automatic old cache cleanup
- `skipWaiting()` and `clients.claim()` for smooth updates
- POST message API for version queries and cache clearing
- Bypasses Firebase/external URLs
- Precaches critical app shell

**Precached Assets:**
- index.html, main.dart.js, flutter.js
- manifest.json, favicon.png
- install-prompt.js
- All icon files
- logo_main.png

### 4. **Update Service** (`lib/services/update_service.dart`)
Dart service for managing PWA updates on web platform.

**Features:**
- Listens for service worker update messages
- Checks for updates every 30 minutes
- Initial check 5 seconds after launch
- Stream-based notification system
- Version query support
- Cache clearing utility
- Web-only (gracefully handles non-web platforms)

**Methods:**
- `initialize()` - Setup service worker listeners
- `checkForUpdate()` - Manually trigger update check
- `applyUpdate()` - Reload page with new version
- `getCurrentVersion()` - Query active service worker version
- `clearCache()` - Debug utility to clear all caches

### 5. **Update Banner Widget** (`lib/widgets/update_banner.dart`)
Flutter widget that displays Material banner when updates are available.

**Features:**
- Automatic detection via UpdateService stream
- Material banner UI (navy blue background, gold button)
- Two actions: "Later" (dismiss) or "Update Now" (apply)
- Analytics integration for tracking user actions
- Non-intrusive, stays until user acts
- Shows loading indicator during update

**Analytics Events:**
- `pwa_update_detected` - New version available
- `pwa_update_dismissed` - User clicked "Later"
- `pwa_update_applied` - User clicked "Update Now"

### 6. **Main App Integration** (`lib/main.dart`)
**Changes:**
- Added `UpdateService` initialization in `main()`
- Added `UpdateBanner` widget to app home
- Version bumped to 1.0.1+2

---

## 🚀 Deployment Process

### 1. Build the Web App
```bash
flutter build web --release
```

### 2. Deploy to Firebase Hosting
```bash
firebase deploy --only hosting
```

### 3. Verify Deployment
- Visit: https://integrity-tools.web.app
- Check service worker version in DevTools → Application → Service Workers
- Test install prompt (may need to clear localStorage and visit twice)

---

## 🧪 Testing Checklist

### Install Prompt Testing
- [ ] Open app in incognito mode
- [ ] Install banner appears after 2 seconds on first visit
- [ ] Click "Install" - app installs to home screen
- [ ] Click "Not now" - banner dismisses and doesn't reappear
- [ ] Check Analytics for events

### Update Testing
- [ ] Make a change and redeploy with new version
- [ ] Visit existing app
- [ ] "Update Available" banner appears
- [ ] Click "Later" - banner dismisses
- [ ] Refresh page - banner reappears
- [ ] Click "Update Now" - app reloads with new version
- [ ] Check Analytics for update events

### Offline Testing
- [ ] Open app while online
- [ ] Go offline (DevTools → Network → Offline)
- [ ] Navigate between screens - should still work
- [ ] Refresh page - loads from cache
- [ ] Calculator tools work offline
- [ ] Go back online - data syncs

### Cross-Browser Testing
- [ ] Chrome (desktop & Android)
- [ ] Safari (desktop & iOS)
- [ ] Edge (desktop)
- [ ] Firefox (desktop)

---

## 📊 Analytics Dashboard

### New Events to Monitor

**Install Funnel:**
1. `pwa_install_prompt_shown` - How many users see the prompt
2. `pwa_install_prompt_action` (action: accepted/dismissed) - User response
3. `pwa_installed` - Successful installations
4. `pwa_launched` - App opens in standalone mode

**Update Funnel:**
1. `pwa_update_detected` - New version available
2. `pwa_update_dismissed` - User delays update
3. `pwa_update_applied` - User applies update

**Metrics to Track:**
- Install conversion rate (installed / prompt_shown)
- Standalone usage percentage (launched / total_visits)
- Update adoption rate (applied / detected)
- Time to update (detected → applied)

---

## 🔧 Configuration

### Visit Threshold for Install Prompt
**Current:** 1 visit (shows immediately on first visit)  
**To Change:** Edit `web/install-prompt.js` line 176:
```javascript
if (visitCount >= 1) {  // Change this number
```

### Update Check Frequency
**Current:** Every 30 minutes  
**To Change:** Edit `lib/services/update_service.dart` line 67:
```dart
Timer.periodic(const Duration(minutes: 30), (timer) {
```

### Service Worker Version
**Current:** v1.0.1  
**To Change:** Edit `web/service-worker.js` line 4:
```javascript
const CACHE_VERSION = 'v1.0.1';  // Increment this
```

**And** `pubspec.yaml` line 20:
```yaml
version: 1.0.1+2  # Increment this
```

---

## 🎨 Customization

### Install Banner Styling
Edit `web/install-prompt.js` lines 40-60 for colors, fonts, sizes.

**Current Colors:**
- Background: `#1b325b` (Navy Blue)
- Accent: `#fbcd0f` (Gold)
- Font: Noto Sans

### Update Banner Styling
Edit `lib/widgets/update_banner.dart` lines 52-82.

**Current Design:**
- Material Banner at top of screen
- Navy blue background with gold button
- Icon: `Icons.system_update`
- Two actions: "Later" (text button), "Update Now" (elevated button)

---

## 📱 Browser Support

### Install Prompt
- ✅ Chrome 67+ (Android, Desktop)
- ✅ Edge 79+
- ✅ Samsung Internet 8.2+
- ⚠️ Safari (iOS/macOS) - Uses native "Add to Home Screen"
- ❌ Firefox - No install prompt support

### Service Worker
- ✅ All modern browsers
- ✅ Chrome, Edge, Firefox, Safari
- ❌ IE11 and older

---

## 🐛 Troubleshooting

### Install Prompt Not Showing
1. Check if criteria met:
   - HTTPS (or localhost)
   - Valid manifest.json
   - Service worker registered
   - Not already installed
   - Meet browser engagement heuristics
2. Check localStorage for `pwa_install_dismissed` or `pwa_installed`
3. Clear localStorage and try again
4. Check visit count in console logs

### Update Banner Not Appearing
1. Check service worker version in DevTools
2. Verify new version is deployed (check Firebase Hosting)
3. Hard refresh (Ctrl+Shift+R) to force update check
4. Check browser console for UpdateService logs
5. Verify UpdateBanner widget is in widget tree

### Service Worker Not Updating
1. Close all tabs with the app
2. Unregister old service worker in DevTools
3. Hard refresh page
4. Check `CACHE_VERSION` is incremented
5. Verify new SW file is deployed

### Caching Issues
1. Open DevTools → Application → Cache Storage
2. Delete all caches manually
3. Unregister service worker
4. Hard refresh
5. Or use UpdateService.clearCache() method

---

## 📈 Expected Performance Improvements

### Load Time
- **First Visit:** ~3-5 seconds (network dependent)
- **Repeat Visits:** ~0.5-1 second (cache-first)
- **Offline:** Instant (cache only)

### Conversion Rates
- **Install Rate:** 15-25% of eligible users
- **Update Adoption:** 70-90% within 24 hours
- **Offline Usage:** 5-10% of sessions

### User Experience
- Native app-like feel on mobile
- Instant loading after first visit
- Works completely offline
- Push notifications ready (future)
- No app store friction

---

## 🔐 Security Considerations

### HTTPS Required
PWA features require HTTPS. Firebase Hosting provides this automatically.

### Service Worker Scope
Service worker has access to all same-origin requests. Current scope: `/`

### Cache Security
Cached content is stored locally. Sensitive data should not be cached. Current implementation excludes:
- Firebase Auth tokens
- Firestore data (network-first)
- Firebase Storage URLs

---

## 🚨 Known Limitations

1. **iOS Safari:** Install prompt doesn't work (Apple's choice). Users must manually "Add to Home Screen"
2. **Firefox:** No install prompt support
3. **Shortcuts:** Only work on Android (Chrome/Edge)
4. **Push Notifications:** Require user permission, not yet implemented
5. **Background Sync:** Not yet implemented (future enhancement)

---

## 📚 Resources

- [MDN PWA Guide](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps)
- [Google PWA Checklist](https://web.dev/pwa-checklist/)
- [Service Worker API](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API)
- [Web App Manifest](https://developer.mozilla.org/en-US/docs/Web/Manifest)
- [beforeinstallprompt](https://developer.mozilla.org/en-US/docs/Web/API/BeforeInstallPromptEvent)

---

## 📝 Version History

### v1.0.1+2 (February 10, 2026)
- ✅ Added install prompt system
- ✅ Enhanced manifest with shortcuts
- ✅ Advanced service worker with version-based caching
- ✅ Created update notification system
- ✅ Integrated analytics tracking
- ✅ Complete documentation

### v1.0.0+1 (Previous)
- Basic PWA with simple service worker
- Basic manifest
- No install prompt
- No update notifications

---

## 🎯 Future Enhancements

1. **Push Notifications** - Alert users of urgent updates
2. **Background Sync** - Sync reports when connection restored
3. **Periodic Background Sync** - Auto-fetch updates daily
4. **Share Target** - Share files to the app
5. **File Handling** - Open .csv/.xlsx files directly
6. **Shortcuts Expansion** - Add more quick actions
7. **A/B Testing** - Test different install prompts
8. **Update Scheduling** - Let users schedule updates

---

**Implementation Complete! 🎉**  
All PWA optimizations are now live and ready for deployment.
