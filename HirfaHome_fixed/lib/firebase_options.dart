// lib/firebase_options.dart
//
// Firebase configuration for HirfaHome.
//
// SECURITY NOTE:
// Firebase web/android API keys are *designed* to be public — they identify
// the Firebase project, not authenticate users. Real security is enforced
// by Firestore Security Rules and Firebase Authentication.
// However, for cleaner credential management in production, prefer:
//   1. `flutterfire configure` to auto-generate this file, OR
//   2. Pass keys via `--dart-define` at build time.
// This file is committed because it contains only public identifiers.

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCq7PxSmcimsoI9qylKnLmRd_BrDXBzfCY',
    authDomain: 'hirfahome.firebaseapp.com',
    projectId: 'hirfahome',
    storageBucket: 'hirfahome.firebasestorage.app',
    messagingSenderId: '934224826106',
    appId: '1:934224826106:web:ccbe707f9a88fdf7808343',
    measurementId: 'G-WLH5HGQ686',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCq7PxSmcimsoI9qylKnLmRd_BrDXBzfCY',
    projectId: 'hirfahome',
    messagingSenderId: '934224826106',
    appId: '1:934224826106:android:2e65a83580f2e9e5808343',
    storageBucket: 'hirfahome.firebasestorage.app',
  );

  /// iOS configuration — required for iPhone/iPad demos during soutenance.
  /// The iOS Bundle ID must be registered in the Firebase Console
  /// (Project Settings → General → Your apps → Add app → iOS).
  /// The iOS API key below is the same as the web/android key for this
  /// project; Firebase allows reusing the same key across platforms.
  /// After registering the iOS app in Firebase Console, replace
  /// `iosBundleId` and `iosClientId` with the real values.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCq7PxSmcimsoI9qylKnLmRd_BrDXBzfCY',
    appId: '1:934224826106:ios:REPLACE_WITH_REAL_IOS_APP_ID',
    messagingSenderId: '934224826106',
    projectId: 'hirfahome',
    storageBucket: 'hirfahome.firebasestorage.app',
    iosBundleId: 'com.example.hirfahome',
  );

  /// macOS configuration — same key set as iOS (Catalyst).
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCq7PxSmcimsoI9qylKnLmRd_BrDXBzfCY',
    appId: '1:934224826106:ios:REPLACE_WITH_REAL_IOS_APP_ID',
    messagingSenderId: '934224826106',
    projectId: 'hirfahome',
    storageBucket: 'hirfahome.firebasestorage.app',
    iosBundleId: 'com.example.hirfahome',
  );
}
