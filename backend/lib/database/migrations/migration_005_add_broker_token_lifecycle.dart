import 'package:backend/database/migrations/migration.dart';
import 'package:postgres/postgres.dart';

class Migration005AddBrokerTokenLifecycle extends Migration {
  @override
  int get version => 5;

  @override
  String get name => 'add_broker_token_lifecycle';

  @override
  Future<void> up(TxSession session) async {
    await session.execute('''
      ALTER TABLE broker_connections
      ADD COLUMN refresh_token TEXT
    ''');

    await session.execute('''
      ALTER TABLE broker_connections
      ADD COLUMN access_token_expires_at TIMESTAMPTZ
    ''');
  }
}