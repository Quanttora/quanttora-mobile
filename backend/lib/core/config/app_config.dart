import 'package:dotenv/dotenv.dart';

class AppConfig {
  static final DotEnv _env = DotEnv()..load();

  static String get upstoxClientId =>
      _env['UPSTOX_CLIENT_ID'] ?? '';

  static String get upstoxClientSecret =>
      _env['UPSTOX_CLIENT_SECRET'] ?? '';

  static String get upstoxRedirectUri =>
      _env['UPSTOX_REDIRECT_URI'] ?? '';
}