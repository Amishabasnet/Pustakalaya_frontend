import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  AppConfig._();

  static const int _port = 5000;

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:$_port/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:$_port/api';
    } catch (_) {
      // Platform isn't available in some non-IO environments; fall through.
    }
    return 'http://localhost:$_port/api';
  }
}
