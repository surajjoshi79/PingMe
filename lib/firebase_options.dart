import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB32ekwb-AWjdaLHS2reGuL-jNuaXLJUOs',
    appId: '1:311589812798:android:883cb7faf525494450ef6f',
    messagingSenderId: '311589812798',
    projectId: 'pingme-409d8',
    storageBucket: 'pingme-409d8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBBA5Xi_zSoCAfBe-mgQlUhlJWe_OIctn4',
    appId: '1:311589812798:ios:32b4aec7c42b208d50ef6f',
    messagingSenderId: '311589812798',
    projectId: 'pingme-409d8',
    storageBucket: 'pingme-409d8.firebasestorage.app',
    androidClientId: '311589812798-3r2fsq2i33bneriv24r2j3b8oka0kp52.apps.googleusercontent.com',
    iosClientId: '311589812798-j6l6tmjbsc15adci353b8ga6jpc81e61.apps.googleusercontent.com',
    iosBundleId: 'com.example.chatApp',
  );

}