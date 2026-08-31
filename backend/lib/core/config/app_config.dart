import 'package:dotenv/dotenv.dart';

class AppConfig {
  AppConfig._();

  static final DotEnv _env = DotEnv()..load();

  static String get upstoxClientId => _env['UPSTOX_CLIENT_ID'] ?? '';

  static String get upstoxClientSecret => _env['UPSTOX_CLIENT_SECRET'] ?? '';

  static String get upstoxRedirectUri => _env['UPSTOX_REDIRECT_URI'] ?? '';

  static String get marketauxApiToken => _env['MARKETAUX_API_TOKEN'] ?? '';

  static String get supabaseUrl => _required('SUPABASE_URL');

  static String get supabasePublishableKey =>
      _required('SUPABASE_PUBLISHABLE_KEY');

  static String get databaseHost => _required('DATABASE_HOST');

  static int get databasePort =>
      int.tryParse(_required('DATABASE_PORT')) ?? 5432;

  static String get databaseName => _required('DATABASE_NAME');

  static String get databaseUser => _required('DATABASE_USER');

  static String get databasePassword => _required('DATABASE_PASSWORD');

  static bool get databaseSsl =>
      (_env['DATABASE_SSL'] ?? 'false').toLowerCase() == 'true';

  static String _required(String key) {
    final value = _env[key]?.trim();

    if (value == null || value.isEmpty) {
      throw StateError('Missing required environment variable: $key');
    }

    return value;
  }
}
