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
    apiKey: "AIzaSyABx2f4VCyvuzjYMTn_kaGoLQcXX9CDhFc",
    appId: "1:415319249838:web:57ca345358811a2b942e3f",
    messagingSenderId: "415319249838",
    projectId: "ndt-toolkit",
    storageBucket: "ndt-toolkit.firebasestorage.app",
    authDomain: "ndt-toolkit.firebaseapp.com",
    measurementId: "G-9Y2TN73N9R"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyABx2f4VCyvuzjYMTn_kaGoLQcXX9CDhFc',
    appId: '1:415319249838:android:PLACEHOLDER',
    messagingSenderId: '415319249838',
    projectId: 'ndt-toolkit',
    storageBucket: 'ndt-toolkit.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyABx2f4VCyvuzjYMTn_kaGoLQcXX9CDhFc',
    appId: '1:415319249838:ios:PLACEHOLDER',
    messagingSenderId: '415319249838',
    projectId: 'ndt-toolkit',
    storageBucket: 'ndt-toolkit.firebasestorage.app',
    iosClientId: 'PLACEHOLDER.apps.googleusercontent.com',
    iosBundleId: 'com.ndttoolkit.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyABx2f4VCyvuzjYMTn_kaGoLQcXX9CDhFc',
    appId: '1:415319249838:ios:PLACEHOLDER',
    messagingSenderId: '415319249838',
    projectId: 'ndt-toolkit',
    storageBucket: 'ndt-toolkit.firebasestorage.app',
    iosClientId: 'PLACEHOLDER.apps.googleusercontent.com',
    iosBundleId: 'com.ndttoolkit.app',
  );
} 