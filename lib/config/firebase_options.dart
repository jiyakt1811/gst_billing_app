import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyCcjU2bfaTYXOg6CZs8J2VuHkHsMh3uKB8",
      authDomain: "mymaf-b1901.firebaseapp.com",
      projectId: "mymaf-b1901",
      storageBucket: "mymaf-b1901.appspot.com",
      messagingSenderId: "59339716312",
      appId: "1:59339716312:web:dc9344173c0b170c7409ad"
  );
} 