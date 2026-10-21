import 'package:flutter/foundation.dart';

/// Where the app finds the server, and who the demo user is.
///
/// Both can be set at build time without changing code:
///
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8080
///   flutter build apk --dart-define=API_BASE_URL=http://192.168.1.20:8080
///
/// A physical phone cannot reach your computer through `localhost`; use the
/// computer's Wi-Fi address that the server prints when it starts.
abstract final class ApiConfig {
  static const _baseUrlOverride = String.fromEnvironment('API_BASE_URL');

  /// The server address used by the shared [ApiClient].
  ///
  /// Defaults: the Android emulator reaches the host computer at 10.0.2.2;
  /// everything else (web, desktop, iOS simulator) uses localhost.
  static Uri get baseUrl {
    if (_baseUrlOverride.isNotEmpty) return Uri.parse(_baseUrlOverride);
    final isAndroid =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    return Uri.parse(
      isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080',
    );
  }

  /// The single demo identity used until real accounts exist.
  /// Override with --dart-define=DEMO_USER_ID=someone-else to act as a
  /// second user (for example, on a second phone during the demo).
  static const demoUserId = String.fromEnvironment(
    'DEMO_USER_ID',
    defaultValue: 'demo-user',
  );
}
