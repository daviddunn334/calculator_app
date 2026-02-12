# FIREBASE CRASHLYTICS SETUP

## Overview

Firebase Crashlytics is now integrated into the Integrity Tools app to automatically collect crash reports and help identify and fix issues quickly. This document explains the implementation and how to use Crashlytics in production.

## What Was Implemented

### 1. Automatic Crash Reporting
- **Fatal Errors**: All uncaught Flutter errors are automatically sent to Firebase Crashlytics
- **Async Errors**: Uncaught asynchronous errors are also captured
- **Platform Crashes**: Native Android and iOS crashes are reported
- **Zero Configuration**: No additional code needed in features - crashes are automatically tracked

### 2. Files Modified

#### Dependencies (`pubspec.yaml`)
- Added `firebase_crashlytics: ^3.4.9`

#### Android Configuration
- **`android/build.gradle`**: Added Crashlytics Gradle plugin
- **`android/app/build.gradle`**: Applied Crashlytics plugin for build-time integration

#### iOS Configuration
- **`ios/Podfile`**: Added debug symbol upload configuration for crash symbolication

#### App Initialization (`lib/main.dart`)
- Imported `firebase_crashlytics` and `dart:ui` packages
- Configured `FlutterError.onError` to send Flutter errors to Crashlytics
- Configured `PlatformDispatcher.instance.onError` to capture async errors

## How It Works

### Automatic Crash Collection

When the app crashes or encounters an unhandled error:

1. **Flutter Errors** (synchronous):
   - Caught by `FlutterError.onError`
   - Sent to Crashlytics with full stack trace
   - Marked as fatal

2. **Async Errors**:
   - Caught by `PlatformDispatcher.instance.onError`
   - Includes errors from Futures, Streams, etc.
   - Sent to Crashlytics with context

3. **Native Crashes**:
   - Android: Caught by Firebase SDK
   - iOS: Caught by Firebase SDK
   - Includes device info, OS version, app version

### What Gets Reported

Each crash report includes:
- **Stack trace**: Full error trace for debugging
- **Device information**: Model, OS version, memory, disk space
- **App version**: Version number from pubspec.yaml
- **User context**: Anonymous user ID (no PII)
- **Timestamp**: When the crash occurred
- **Breadcrumbs**: Recent app activities (optional, not implemented in basic setup)

## Viewing Crash Reports

### Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **integrity-tools**
3. Navigate to **Crashlytics** in the left sidebar
4. View crashes organized by:
   - **Fatal crashes**: App-breaking errors
   - **Non-fatal errors**: Handled errors (if you add manual logging)
   - **Velocity alerts**: Sudden spike in crashes
   - **Affected users**: Number of users impacted

### Crash Dashboard Features

- **Issue clustering**: Similar crashes grouped together
- **Stack trace**: Full error details with line numbers
- **Device breakdown**: See which devices are affected
- **OS versions**: Identify OS-specific issues
- **Timeline**: When crashes started occurring
- **Logs**: Recent app activity before crash (if implemented)

## Testing Crashlytics

### Force a Test Crash (Development Only)

Add this button temporarily to any screen to test:

```dart
ElevatedButton(
  onPressed: () {
    FirebaseCrashlytics.instance.crash(); // Force a crash
  },
  child: const Text('Test Crash (Dev Only)'),
)
```

Or throw an error manually:

```dart
throw Exception('Test crash for Crashlytics');
```

**Important**: Remove test crash code before production deployment!

### Verify Integration

1. **Run the app** on a physical device or emulator
2. **Force a test crash** using the code above
3. **Wait 5-10 minutes** for reports to appear in Firebase Console
4. **Check Crashlytics dashboard** for the test crash

**Note**: Crashes may not appear immediately - Firebase batches reports for efficiency.

## Production Best Practices

### 1. Version Management

Always bump version numbers before releases:
```yaml
# pubspec.yaml
version: 1.0.4+5  # Increment for each release
```

This helps track which version has crashes.

### 2. Enable Crashlytics for Release Builds Only (Optional)

If you want to disable Crashlytics in debug mode:

```dart
// In main.dart
if (kReleaseMode) {
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
}
```

### 3. ProGuard/R8 Configuration (Android)

For Android release builds, ensure obfuscation doesn't break crash reports. The current setup handles this automatically, but if you customize ProGuard rules, preserve Firebase classes.

### 4. dSYM Upload (iOS)

iOS debug symbols are automatically uploaded when building with Xcode. For manual builds or CI/CD:

```bash
# Upload dSYMs manually if needed
./ios/Pods/FirebaseCrashlytics/upload-symbols \
  -gsp ios/Runner/GoogleService-Info.plist \
  -p ios path/to/dSYMs
```

## Advanced Usage (Optional)

If you want more detailed crash reporting, you can add manual logging:

### Log Custom Events

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Log a custom message (breadcrumb)
await FirebaseCrashlytics.instance.log('User clicked button X');

// Set custom keys for context
await FirebaseCrashlytics.instance.setCustomKey('user_role', 'admin');
await FirebaseCrashlytics.instance.setCustomKey('current_screen', 'reports');

// Set user identifier (not PII)
await FirebaseCrashlytics.instance.setUserIdentifier('user_12345');
```

### Record Non-Fatal Errors

```dart
try {
  // Some risky operation
  await riskyFunction();
} catch (error, stackTrace) {
  // Log error to Crashlytics without crashing
  await FirebaseCrashlytics.instance.recordError(
    error,
    stackTrace,
    reason: 'Failed to load data',
    fatal: false,
  );
}
```

### Integration with Analytics Service

You can enhance the existing `AnalyticsService` to also log to Crashlytics:

```dart
// In lib/services/analytics_service.dart
Future<void> logError({
  required String errorMessage,
  required String screen,
  String? stackTrace,
}) async {
  // Log to Analytics
  await logEvent(
    name: 'error_occurred',
    parameters: {
      'error_message': errorMessage,
      'screen': screen,
      if (stackTrace != null) 'stack_trace': stackTrace.substring(0, 100),
    },
  );
  
  // Also log to Crashlytics
  await FirebaseCrashlytics.instance.log('Error in $screen: $errorMessage');
}
```

## Troubleshooting

### Crashes Not Appearing in Console

1. **Wait longer**: Reports can take 5-10 minutes to appear
2. **Check internet**: Device must have connectivity to upload reports
3. **Verify Firebase config**: Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are present
4. **Check build type**: Debug builds may have delays; test with release builds

### Symbol Upload Issues (iOS)

If iOS crashes show unsymbolicated stack traces:
- Ensure `DEBUG_INFORMATION_FORMAT = 'dwarf-with-dsym'` in Podfile (already set)
- Rebuild the app to generate new dSYMs
- Check Xcode build settings for "Generate Debug Symbols"

### Build Errors

If you encounter build errors after integration:
1. Run `flutter clean`
2. Run `flutter pub get`
3. For iOS: `cd ios && pod install && cd ..`
4. For Android: Rebuild with `flutter build apk`

## Monitoring & Alerts

### Set Up Velocity Alerts

1. Go to **Crashlytics** in Firebase Console
2. Click **Settings** (gear icon)
3. Enable **Velocity alerts**
4. Configure email notifications for crash spikes

### Integrate with Slack/Email

Firebase can send notifications to:
- **Email**: Add team emails in Firebase settings
- **Slack**: Use Firebase Cloud Functions to forward alerts
- **Jira**: Create issues automatically for new crashes

## Privacy Considerations

### Data Collection

Crashlytics collects:
- ✅ Crash stack traces
- ✅ Device model and OS version
- ✅ App version
- ✅ Anonymous crash identifier
- ❌ **NO** personally identifiable information (PII)
- ❌ **NO** user names or emails (unless manually logged)

### Compliance

- **GDPR**: Crashlytics is GDPR-compliant by default (no PII)
- **User Consent**: No consent required for crash reporting (technical necessity)
- **Data Retention**: Crashes retained for 90 days by default

## Summary

✅ **Automatic crash reporting** is now active  
✅ **Zero configuration** needed for basic features  
✅ **Android and iOS** both supported  
✅ **Web** gracefully handled (Crashlytics not available on web)  
✅ **Production-ready** implementation  

The app will now automatically report crashes to Firebase, helping you identify and fix issues before they affect too many users.

## Next Steps

1. ✅ Test crash reporting with a forced crash
2. ✅ Monitor Crashlytics dashboard for the first week
3. ⚠️ Set up velocity alerts for crash spikes
4. ⚠️ Configure team notifications
5. ⚠️ Review crashes weekly and prioritize fixes

---

**Firebase Project**: integrity-tools  
**Crashlytics Status**: ✅ Active  
**Implementation Date**: February 11, 2026  
**Documentation Version**: 1.0
