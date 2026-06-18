// lib/firebase_options.dart
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
    appId: '1:934224826106:android:2e65a83580f2e9e5808343', // ← CORRIGÉ
    storageBucket: 'hirfahome.firebasestorage.app',
  );
}