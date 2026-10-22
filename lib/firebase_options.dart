// File generated for Firebase configuration.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCoWUJND2uVRP9nDBlCN0CWTKsFSlMFHiA',
    appId: '1:699791379825:android:0b042146ae56e97f907ad0',
    messagingSenderId: '699791379825',
    projectId: 'justus-b131a',
    storageBucket: 'justus-b131a.firebasestorage.app',
    databaseURL: 'https://justus-b131a-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCoWUJND2uVRP9nDBlCN0CWTKsFSlMFHiA',
    appId: '1:699791379825:web:0b042146ae56e97f907ad0',
    messagingSenderId: '699791379825',
    projectId: 'justus-b131a',
    storageBucket: 'justus-b131a.firebasestorage.app',
    databaseURL: 'https://justus-b131a-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCoWUJND2uVRP9nDBlCN0CWTKsFSlMFHiA',
    appId: '1:699791379825:ios:0b042146ae56e97f907ad0',
    messagingSenderId: '699791379825',
    projectId: 'justus-b131a',
    storageBucket: 'justus-b131a.firebasestorage.app',
    databaseURL: 'https://justus-b131a-default-rtdb.firebaseio.com',
  );
}
