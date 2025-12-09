import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // Web (Chrome)
    if (kIsWeb) return "http://127.0.0.1:3000";

    // Later for Android emulator:
    // return "http://10.0.2.2:3000";

    return "http://127.0.0.1:3000";
  }
}
