import 'package:backend/database/migrations/migration.dart';
import 'package:postgres/postgres.dart';

class Migration002CreateUserSessions extends Migration {
  @override
  int get version => 2;

  @override
  String get name => 'create_user_sessions';

  @override
  Future<void> up(TxSession session) async {
    await session.execute('''
      CREATE TABLE user_sessions (
        id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

        user_id BIGINT NOT NULL
          REFERENCES users(id)
          ON DELETE CASCADE,

        token_hash TEXT NOT NULL,

        expires_at TIMESTAMPTZ NOT NULL,

        revoked_at TIMESTAMPTZ,

        last_used_at TIMESTAMPTZ,

        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      )
    ''');

    await session.execute('''
      CREATE UNIQUE INDEX user_sessions_token_hash_unique
      ON user_sessions (token_hash)
    ''');

    await session.execute('''
      CREATE INDEX user_sessions_user_id_index
      ON user_sessions (user_id)
    ''');

    await session.execute('''
      CREATE INDEX user_sessions_expires_at_index
      ON user_sessions (expires_at)
    ''');

    await session.execute('''
      CREATE INDEX user_sessions_active_index
      ON user_sessions (user_id, expires_at)
      WHERE revoked_at IS NULL
    ''');
  }
}