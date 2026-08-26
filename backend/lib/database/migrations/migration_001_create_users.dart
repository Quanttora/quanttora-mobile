import 'package:backend/database/migrations/migration.dart';
import 'package:postgres/postgres.dart';

class Migration001CreateUsers extends Migration {
  @override
  int get version => 1;

  @override
  String get name => 'create_users';

  @override
  Future<void> up(TxSession session) async {
    await session.execute('''
      CREATE TABLE users (
        id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

        email TEXT NOT NULL,

        password_hash TEXT NOT NULL,

        display_name TEXT NOT NULL,

        status TEXT NOT NULL DEFAULT 'active'
          CHECK (status IN ('active', 'suspended', 'disabled')),

        email_verified_at TIMESTAMPTZ,

        last_login_at TIMESTAMPTZ,

        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      )
    ''');

    await session.execute('''
      CREATE UNIQUE INDEX users_email_lower_unique
      ON users (LOWER(email))
    ''');

    await session.execute('''
      CREATE INDEX users_status_index
      ON users (status)
    ''');
  }
}