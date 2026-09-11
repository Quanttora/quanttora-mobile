import 'package:backend/database/migrations/migration.dart';
import 'package:postgres/postgres.dart';

class Migration004CreateBrokerConnections extends Migration {
  @override
  int get version => 4;

  @override
  String get name => 'create_broker_connections';

  @override
  Future<void> up(TxSession session) async {
    await session.execute('''
      CREATE TABLE broker_connections (
        id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

        user_id BIGINT NOT NULL
          REFERENCES users(id)
          ON DELETE CASCADE,

        broker TEXT NOT NULL,

        broker_user_id TEXT NOT NULL,

        user_name TEXT NOT NULL,

        email TEXT NOT NULL,

        access_token TEXT NOT NULL,

        extended_token TEXT,

        connected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

        UNIQUE (user_id, broker)
      )
    ''');

    await session.execute('''
      CREATE INDEX broker_connections_user_id_index
      ON broker_connections (user_id)
    ''');

    await session.execute('''
      CREATE INDEX broker_connections_broker_user_id_index
      ON broker_connections (broker_user_id)
    ''');
  }
}