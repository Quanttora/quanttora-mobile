import 'package:backend/database/database.dart';
import 'package:backend/models/broker_connection.dart';
import 'package:backend/services/secure_token_service.dart';
import 'package:postgres/postgres.dart';

class BrokerConnectionRepository {
  static const String _selectColumns = '''
    broker,
    broker_user_id,
    user_name,
    email,
    access_token,
    extended_token,
    refresh_token,
    access_token_expires_at
  ''';

  final SecureTokenService _secureTokenService =
      SecureTokenService.instance;

  Future<void> save(
    BrokerConnection connection, {
    required int quanttoraUserId,
  }) async {
    final encryptedAccessToken =
        await _secureTokenService.encrypt(connection.accessToken);

    final encryptedExtendedToken =
        await _secureTokenService.encrypt(connection.extendedToken);

    final encryptedRefreshToken =
        await _secureTokenService.encrypt(connection.refreshToken);

    await Database.execute(
      Sql.named('''
        INSERT INTO broker_connections (
          user_id,
          broker,
          broker_user_id,
          user_name,
          email,
          access_token,
          extended_token,
          refresh_token,
          access_token_expires_at
        )
        VALUES (
          @userId,
          @broker,
          @brokerUserId,
          @userName,
          @email,
          @accessToken,
          @extendedToken,
          @refreshToken,
          @accessTokenExpiresAt
        )
        ON CONFLICT (user_id, broker)
        DO UPDATE SET
          broker_user_id = EXCLUDED.broker_user_id,
          user_name = EXCLUDED.user_name,
          email = EXCLUDED.email,
          access_token = EXCLUDED.access_token,
          extended_token = EXCLUDED.extended_token,
          refresh_token = EXCLUDED.refresh_token,
          access_token_expires_at = EXCLUDED.access_token_expires_at,
          updated_at = NOW()
      '''),
      parameters: {
        'userId': quanttoraUserId,
        'broker': connection.broker,
        'brokerUserId': connection.userId,
        'userName': connection.userName,
        'email': connection.email,
        'accessToken': encryptedAccessToken,
        'extendedToken': encryptedExtendedToken,
        'refreshToken': encryptedRefreshToken,
        'accessTokenExpiresAt': connection.accessTokenExpiresAt,
      },
    );
  }

  Future<BrokerConnection?> findByQuanttoraUserId(
    int quanttoraUserId,
  ) async {
    final result = await Database.execute(
      Sql.named('''
        SELECT $_selectColumns
        FROM broker_connections
        WHERE user_id = @userId
        LIMIT 1
      '''),
      parameters: {
        'userId': quanttoraUserId,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    final row = result.first;

    final rawAccessToken = row[4] as String;
    final rawExtendedToken = row[5] as String? ?? '';
    final rawRefreshToken = row[6] as String? ?? '';

    final accessToken =
        await _secureTokenService.decrypt(rawAccessToken);

    final extendedToken = rawExtendedToken.isEmpty
        ? ''
        : await _secureTokenService.decrypt(rawExtendedToken);

    final refreshToken = rawRefreshToken.isEmpty
        ? ''
        : await _secureTokenService.decrypt(rawRefreshToken);

    return BrokerConnection(
      broker: row[0] as String,
      userId: row[1] as String,
      userName: row[2] as String,
      email: row[3] as String,
      accessToken: accessToken,
      extendedToken: extendedToken,
      refreshToken: refreshToken,
      accessTokenExpiresAt: row[7] as DateTime?,
    );
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final result = await Database.execute('''
      SELECT
        user_id,
        broker,
        broker_user_id,
        user_name,
        email,
        access_token,
        extended_token,
        refresh_token,
        access_token_expires_at
      FROM broker_connections
      ORDER BY user_id ASC
    ''');

    final connections = <Map<String, dynamic>>[];

    for (final row in result) {
      final quanttoraUserId = row[0] as int;
      final broker = row[1] as String;

      final rawAccessToken = row[5] as String;
      final rawExtendedToken = row[6] as String? ?? '';
      final rawRefreshToken = row[7] as String? ?? '';

      final accessToken =
          await _secureTokenService.decrypt(rawAccessToken);

      final extendedToken = rawExtendedToken.isEmpty
          ? ''
          : await _secureTokenService.decrypt(rawExtendedToken);

      final refreshToken = rawRefreshToken.isEmpty
          ? ''
          : await _secureTokenService.decrypt(rawRefreshToken);

      connections.add({
        'userId': quanttoraUserId,
        'broker': broker,
        'brokerUserId': row[2],
        'userName': row[3],
        'email': row[4],
        'accessToken': accessToken,
        'extendedToken': extendedToken,
        'refreshToken': refreshToken,
        'accessTokenExpiresAt': row[8] as DateTime?,
      });
    }

    return connections;
  }

  Future<void> clearForUser({
    required int quanttoraUserId,
    required String broker,
  }) async {
    await Database.execute(
      Sql.named('''
        DELETE FROM broker_connections
        WHERE user_id = @userId
          AND broker = @broker
      '''),
      parameters: {
        'userId': quanttoraUserId,
        'broker': broker,
      },
    );
  }
}