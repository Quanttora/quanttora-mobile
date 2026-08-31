import 'package:backend/database/migrations/migration.dart';
import 'package:postgres/postgres.dart';

class Migration003AddSupabaseIdentity extends Migration {
  @override
  int get version => 3;

  @override
  String get name => 'add_supabase_identity';

  @override
  Future<void> up(TxSession session) async {
    await session.execute('''
      ALTER TABLE users
      ADD COLUMN supabase_user_id TEXT
    ''');

    await session.execute('''
      CREATE UNIQUE INDEX users_supabase_user_id_unique
      ON users (supabase_user_id)
      WHERE supabase_user_id IS NOT NULL
    ''');
  }
}
