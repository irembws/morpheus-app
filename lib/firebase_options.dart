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
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBAPAYw4siq2G94kCeIgfasoSGVRNLb8KA',
    appId: '1:604130460945:web:319507d60f90dfc8cdb8b0',
    messagingSenderId: '604130460945',
    projectId: 'morpheus-840bd',
    storageBucket: 'morpheus-840bd.appspot.com',
    authDomain: 'morpheus-840bd.firebaseapp.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBAPAYw4siq2G94kCeIgfasoSGVRNLb8KA',
    appId: '1:604130460945:android:319507d60f90dfc8cdb8b0',
    messagingSenderId: '604130460945',
    projectId: 'morpheus-840bd',
    storageBucket: 'morpheus-840bd.appspot.com',
  );
}
