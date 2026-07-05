import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA22ETCzlwKZzXEwVC2VxYR3Tz-NM3jlWE',
    appId: '1:554742916529:android:a58096ade9588eefb4c990',
    messagingSenderId: '554742916529',
    projectId: 'uniboard-fd52f',
    storageBucket: 'uniboard-fd52f.firebasestorage.app',
  );
}