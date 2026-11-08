import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration for the Riphah Portal project
/// (Firebase project: myproject-30b71).
///
/// Only web and Android are configured; other platforms throw.
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
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDaFgayZ3iKsrWHwSr5lUjBo__GX6laI5E',
    authDomain: 'myproject-30b71.firebaseapp.com',
    projectId: 'myproject-30b71',
    storageBucket: 'myproject-30b71.firebasestorage.app',
    messagingSenderId: '1039761447730',
    appId: '1:1039761447730:web:f49184c0fe1c2a8ddd552b',
    measurementId: 'G-VQDCZGX6R9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDlTV_-3_qy5XOnHB04ypzJp8wH2X_8hmo',
    authDomain: 'myproject-30b71.firebaseapp.com',
    projectId: 'myproject-30b71',
    storageBucket: 'myproject-30b71.firebasestorage.app',
    messagingSenderId: '1039761447730',
    appId: '1:1039761447730:android:f3d0135dbab93510dd552b',
  );
}
