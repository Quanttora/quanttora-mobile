import 'package:backend/database/database.dart';
import 'package:backend/models/broker_connection.dart';
import 'package:postgres/postgres.dart';

class BrokerConnectionRepository {
  static const String _selectColumns = '''
    broker,
    broker_user_id,
    user_name,
    email,
    access_token,
    extended_token
  ''';

  Future<void> save(
    BrokerConnection connection, {
    required int quanttoraUserId,
  }) async {
    await Database.execute(
      Sql.named('''
        INSERT INTO broker_connections (
          user_id,
          broker,
          broker_user_id,
          user_name,
          email,
          access_token,
          extended_token
        )
        VALUES (
          @userId,
          @broker,
          @brokerUserId,
          @userName,
          @email,
          @accessToken,
          @extendedToken
        )
        ON CONFLICT (user_id, broker)
        DO UPDATE SET
          broker_user_id = EXCLUDED.broker_user_id,
          user_name = EXCLUDED.user_name,
          email = EXCLUDED.email,
          access_token = EXCLUDED.access_token,
          extended_token = EXCLUDED.extended_token,
          updated_at = NOW()
      '''),
      parameters: {
        'userId': quanttoraUserId,
        'broker': connection.broker,
        'brokerUserId': connection.userId,
        'userName': connection.userName,
        'email': connection.email,
        'accessToken': connection.accessToken,
        'extendedToken': connection.extendedToken,
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

    return BrokerConnection(
      broker: row[0] as String,
      userId: row[1] as String,
      userName: row[2] as String,
      email: row[3] as String,
      accessToken: row[4] as String,
      extendedToken: row[5] as String? ?? '',
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
        extended_token
      FROM broker_connections
      ORDER BY user_id ASC
    ''');

    return result
        .map(
          (row) => {
            'userId': row[0],
            'broker': row[1],
            'brokerUserId': row[2],
            'userName': row[3],
            'email': row[4],
            'accessToken': row[5],
            'extendedToken': row[6],
          },
        )
        .toList();
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