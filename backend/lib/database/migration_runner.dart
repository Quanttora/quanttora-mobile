import 'package:backend/database/database.dart';
import 'package:backend/database/migrations/migration.dart';
import 'package:backend/database/migrations/migration_001_create_users.dart';
import 'package:backend/database/migrations/migration_002_create_user_sessions.dart';
import 'package:backend/database/migrations/migration_003_add_supabase_identity.dart';
import 'package:postgres/postgres.dart';

class MigrationRunner {
  MigrationRunner._();

  static final List<Migration> _migrations = [
    Migration001CreateUsers(),
    Migration002CreateUserSessions(),
    Migration003AddSupabaseIdentity(),
  ];

  static Future<void> initialize() async {
    await Database.execute('''
      CREATE TABLE IF NOT EXISTS schema_migrations (
        version INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      )
    ''');
  }

  static Future<void> runPending() async {
    await initialize();

    final appliedResult = await Database.execute('''
      SELECT version
      FROM schema_migrations
      ORDER BY version ASC
    ''');

    final appliedVersions = appliedResult.map((row) => row[0] as int).toSet();

    for (final migration in _migrations) {
      if (appliedVersions.contains(migration.version)) {
        continue;
      }

      await Database.pool.runTx((session) async {
        await migration.up(session);

        await session.execute(
          Sql.named('''
            INSERT INTO schema_migrations (version, name)
            VALUES (@version, @name)
          '''),
          parameters: {'version': migration.version, 'name': migration.name},
        );
      });

      print(
        'Migration applied: '
        '${migration.version} - ${migration.name}',
      );
    }
  }

  static Future<List<Map<String, dynamic>>> getAppliedMigrations() async {
    final result = await Database.execute('''
      SELECT version, name, applied_at
      FROM schema_migrations
      ORDER BY version ASC
      ''');

    return result
        .map((row) => {'version': row[0], 'name': row[1], 'applied_at': row[2]})
        .toList();
  }
}
