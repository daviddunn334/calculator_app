import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyARXBBdfKELC__wx6UlZ1eSx4N1OOQ2tzg",
    appId: "1:107937743545:web:9f730ca6984ece2b1a1168",
    messagingSenderId: "107937743545",
    projectId: "ndt-toolkit-template",
    storageBucket: "ndt-toolkit-template.firebasestorage.app",
    authDomain: "ndt-toolkit-template.firebaseapp.com",
    measurementId: "G-KD4C7R3GCX"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyARXBBdfKELC__wx6UlZ1eSx4N1OOQ2tzg',
    appId: '1:107937743545:android:PLACEHOLDER',
    messagingSenderId: '107937743545',
    projectId: 'ndt-toolkit-template',
    storageBucket: 'ndt-toolkit-template.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyARXBBdfKELC__wx6UlZ1eSx4N1OOQ2tzg',
    appId: '1:107937743545:ios:PLACEHOLDER',
    messagingSenderId: '107937743545',
    projectId: 'ndt-toolkit-template',
    storageBucket: 'ndt-toolkit-template.firebasestorage.app',
    iosBundleId: 'com.example.calculatorApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyARXBBdfKELC__wx6UlZ1eSx4N1OOQ2tzg',
    appId: '1:107937743545:macos:PLACEHOLDER',
    messagingSenderId: '107937743545',
    projectId: 'ndt-toolkit-template',
    storageBucket: 'ndt-toolkit-template.firebasestorage.app',
    iosBundleId: 'com.example.calculatorApp',
  );
} 