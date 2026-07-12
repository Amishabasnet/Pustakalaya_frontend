import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  AppConfig._();

  static const int _port = 5000;

  static String get baseUrl {
    const overrideUrl = String.fromEnvironment('API_BASE_URL');
    if (overrideUrl.isNotEmpty) return overrideUrl;

    // Use loopback IP for web to avoid potential hostname resolution issues
    // and to make CORS troubleshooting more straightforward.
    if (kIsWeb) return 'http://127.0.0.1:$_port/api';

    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:$_port/api';
    } catch (_) {
      // Platform isn't available in some non-IO environments; fall through.
    }

    return 'http://127.0.0.1:$_port/api';
  }
}
