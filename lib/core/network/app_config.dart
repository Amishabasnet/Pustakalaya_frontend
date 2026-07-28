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

  static String get assetBaseUrl {
    final url = baseUrl;
    return url.endsWith('/api') ? url.substring(0, url.length - 4) : url;
  }

  static String? resolveAssetUrl(String? path) {
    if (path == null || path.isEmpty) return null;

    if (path.startsWith('http://') || path.startsWith('https://')) {
      final uri = Uri.tryParse(path);
      final isLoopback =
          uri != null &&
          (uri.host == 'localhost' ||
              uri.host == '127.0.0.1' ||
              uri.host == '10.0.2.2');
      if (!isLoopback) return path;
      return '$assetBaseUrl${uri.path}${uri.hasQuery ? '?${uri.query}' : ''}';
    }

    return '$assetBaseUrl${path.startsWith('/') ? '' : '/'}$path';
  }
}
