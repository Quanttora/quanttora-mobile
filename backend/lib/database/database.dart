import 'package:backend/core/config/app_config.dart';
import 'package:postgres/postgres.dart';

class Database {
  Database._();

  static Pool? _pool;

  static bool get isInitialized => _pool != null;

  static Future<void> initialize() async {
    if (_pool != null) {
      return;
    }

    final pool = Pool.withEndpoints(
      [
        Endpoint(
          host: AppConfig.databaseHost,
          port: AppConfig.databasePort,
          database: AppConfig.databaseName,
          username: AppConfig.databaseUser,
          password: AppConfig.databasePassword,
        ),
      ],
      settings: PoolSettings(
        applicationName: 'quanttora-backend',
        maxConnectionCount: 10,
        maxConnectionAge: const Duration(minutes: 30),
        maxSessionUse: const Duration(minutes: 10),
        maxQueryCount: 1000,
        connectTimeout: const Duration(seconds: 10),
        queryTimeout: const Duration(seconds: 30),
        sslMode: AppConfig.databaseSsl
            ? SslMode.require
            : SslMode.disable,
      ),
    );

    try {
      await pool.execute('SELECT 1');
      _pool = pool;

      print('========================================');
      print('Quanttora Database Connected');
      print('Host: ${AppConfig.databaseHost}');
      print('Port: ${AppConfig.databasePort}');
      print('Database: ${AppConfig.databaseName}');
      print('User: ${AppConfig.databaseUser}');
      print('SSL: ${AppConfig.databaseSsl}');
      print('========================================');
    } catch (e) {
      await pool.close(force: true);
      rethrow;
    }
  }

  static Pool get pool {
    final pool = _pool;

    if (pool == null) {
      throw StateError(
        'Database has not been initialized. '
        'Call Database.initialize() first.',
      );
    }

    return pool;
  }

  static Future<Result> execute(
    Object query, {
    Object? parameters,
    bool ignoreRows = false,
  }) {
    return pool.execute(
      query,
      parameters: parameters,
      ignoreRows: ignoreRows,
    );
  }

  static Future<void> close() async {
    final pool = _pool;

    if (pool == null) {
      return;
    }

    _pool = null;
    await pool.close(force: true);
  }
}