// File generated by FlutterFire CLI.
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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyDuvMZlxco8WiGJBBUOL26FD28yYzKumY0',
    appId: '1:584648748967:web:8cad65d88c3c8cd5939082',
    messagingSenderId: '584648748967',
    projectId: 'wordbrige-3eaa2',
    authDomain: 'wordbrige-3eaa2.firebaseapp.com',
    storageBucket: 'wordbrige-3eaa2.firebasestorage.app',
    measurementId: 'G-NH2866WJPQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBapF06uc6p9fa_lu_ZnWHiITPN5-MvhOk',
    appId: '1:584648748967:android:20fa5fb0097bdbf9939082',
    messagingSenderId: '584648748967',
    projectId: 'wordbrige-3eaa2',
    storageBucket: 'wordbrige-3eaa2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAI_iXDTptMllnW5JE3wgSDirURysCwAgM',
    appId: '1:584648748967:ios:558e6ae2b2be677f939082',
    messagingSenderId: '584648748967',
    projectId: 'wordbrige-3eaa2',
    storageBucket: 'wordbrige-3eaa2.firebasestorage.app',
    iosBundleId: 'com.example.wordbridge',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAI_iXDTptMllnW5JE3wgSDirURysCwAgM',
    appId: '1:584648748967:ios:558e6ae2b2be677f939082',
    messagingSenderId: '584648748967',
    projectId: 'wordbrige-3eaa2',
    storageBucket: 'wordbrige-3eaa2.firebasestorage.app',
    iosBundleId: 'com.example.wordbridge',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDuvMZlxco8WiGJBBUOL26FD28yYzKumY0',
    appId: '1:584648748967:web:01fe81fe9e516823939082',
    messagingSenderId: '584648748967',
    projectId: 'wordbrige-3eaa2',
    authDomain: 'wordbrige-3eaa2.firebaseapp.com',
    storageBucket: 'wordbrige-3eaa2.firebasestorage.app',
    measurementId: 'G-S5636F7JQ0',
  );
}
