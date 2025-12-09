// Minimal firebase options placeholder to avoid analyzer errors when
// the `firebase_core` package is not present. If you intend to use
// Firebase, add `firebase_core` to your pubspec and replace this
// file with the generated `firebase_options.dart` from the CLI.

class DefaultFirebaseOptions {
  static Map<String, Object> get currentPlatform => android;

  static const Map<String, Object> android = {
    'apiKey': 'REDACTED',
    'appId': '1:1234567890:android:abcdef123456',
    'messagingSenderId': '1234567890',
    'projectId': 'ainetzero-27c6f',
    'storageBucket': 'ainetzero-27c6f.firebasestorage.app',
    'databaseURL': 'https://ainetzero-27c6f-default-rtdb.asia-southeast1.firebasedatabase.app',
  };
}
