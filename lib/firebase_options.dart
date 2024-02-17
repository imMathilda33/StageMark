// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyDJEQTeEfQj5bpHSaVub0CJlx7sJDlhH9M',
    appId: '1:974571383157:web:891f1833ce9bb5fbb80b3c',
    messagingSenderId: '974571383157',
    projectId: 'casaapp-99e94',
    authDomain: 'casaapp-99e94.firebaseapp.com',
    databaseURL: 'https://casaapp-99e94-default-rtdb.firebaseio.com',
    storageBucket: 'casaapp-99e94.appspot.com',
    measurementId: 'G-TD5XPL2LXY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCzY-QAVvKSV6I9UrE-xk9el2FfOm3MDAQ',
    appId: '1:974571383157:android:6ff3ba38bc978ad6b80b3c',
    messagingSenderId: '974571383157',
    projectId: 'casaapp-99e94',
    databaseURL: 'https://casaapp-99e94-default-rtdb.firebaseio.com',
    storageBucket: 'casaapp-99e94.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB7lMA7tmd-RfTWK66jQ-y14QfGp2Hbmrk',
    appId: '1:974571383157:ios:1a8c1137ccc78a4fb80b3c',
    messagingSenderId: '974571383157',
    projectId: 'casaapp-99e94',
    databaseURL: 'https://casaapp-99e94-default-rtdb.firebaseio.com',
    storageBucket: 'casaapp-99e94.appspot.com',
    iosBundleId: 'com.example.casaApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB7lMA7tmd-RfTWK66jQ-y14QfGp2Hbmrk',
    appId: '1:974571383157:ios:de8e7b71a1744bc1b80b3c',
    messagingSenderId: '974571383157',
    projectId: 'casaapp-99e94',
    databaseURL: 'https://casaapp-99e94-default-rtdb.firebaseio.com',
    storageBucket: 'casaapp-99e94.appspot.com',
    iosBundleId: 'com.example.casaApp.RunnerTests',
  );
}