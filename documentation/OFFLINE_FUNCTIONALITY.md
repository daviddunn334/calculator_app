# Offline Functionality for Calculator App

This document explains the implementation of offline functionality for the calculator tools in the Integrity Tools app.

## What Was Implemented

1. **Service Worker**: A custom service worker that caches app assets and enables offline functionality.
2. **Offline Data Storage**: Local storage for calculator data using SharedPreferences.
3. **Offline Detection**: Real-time detection of network status changes.
4. **Offline UI Indicators**: Visual indicators when the app is in offline mode.
5. **PWA Configuration**: Enhanced web manifest and configuration for better PWA support.

## How It Works

### Service Worker

The service worker (`web/service-worker.js`) is responsible for:
- Caching app assets during installation
- Serving cached assets when offline
- Managing cache updates
- Handling fetch requests with appropriate strategies

### Offline Service

The `OfflineService` class (`lib/services/offline_service.dart`) provides:
- Network connectivity detection
- Local data storage for calculator inputs and results
- Methods to save and load calculator data

### UI Components

- `OfflineIndicator` widget shows when the app is offline
- Calculator screens display offline status and save data locally
- The main app bypasses authentication when offline to allow direct access to calculator tools

## Testing Offline Functionality

1. **Deploy the web app**:
   ```
   flutter build web
   ```

2. **Serve the app** (for testing locally):
   ```
   cd build/web
   python -m http.server 8000
   ```

3. **Access the app** in a browser at `http://localhost:8000`

4. **Test offline functionality**:
   - Open the app and navigate to the calculator tools
   - Use Chrome DevTools to simulate offline mode (Network tab > Offline)
   - Verify that calculator tools still work
   - Enter data in calculators and verify it's saved when going offline/online
   - Close and reopen the browser while offline to verify the app loads from cache

5. **Install as PWA**:
   - Click the install button in Chrome's address bar
   - Verify the app works offline after installation

## Deployment Considerations

1. **HTTPS Required**: Service workers require HTTPS in production.
2. **Cache Versioning**: The service worker includes cache versioning to manage updates.
3. **Firebase Fallback**: The app gracefully handles Firebase unavailability when offline.

## Future Improvements

1. **Background Sync**: Implement background sync to save data to Firebase when connection is restored.
2. **Offline-First Architecture**: Further refine the app to work offline-first.
3. **Improved Caching Strategies**: Implement more sophisticated caching strategies for different types of assets.
4. **Push Notifications**: Add push notifications for important updates when back online.
