// Generated from the project's GoogleService-Info.plist (iOS) and
// google-services.json (Android). Passing these explicitly to
// Firebase.initializeApp avoids relying on the native config files being
// bundled into the app (the iOS plist was not added to the Xcode target).
//
// If you later run `flutterfire configure`, it will regenerate this file.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for '
          '$defaultTargetPlatform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB-GV3H3OVs1j-Hwia3ptJRGHEicEuk8RA',
    appId: '1:244398434586:android:11ca4299bb4853cc67a4a3',
    messagingSenderId: '244398434586',
    projectId: 'medicare-494ab',
    storageBucket: 'medicare-494ab.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBBSTd7stTPQ9bR0L3wionUgec714h-iJk',
    appId: '1:244398434586:ios:b6923dddc86452b067a4a3',
    messagingSenderId: '244398434586',
    projectId: 'medicare-494ab',
    storageBucket: 'medicare-494ab.firebasestorage.app',
    iosBundleId: 'com.example.mediforze',
  );
}
