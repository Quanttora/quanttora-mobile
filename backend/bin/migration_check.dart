import 'package:backend/database/database.dart';
import 'package:backend/database/migration_runner.dart';

Future<void> main() async {
  try {
    await Database.initialize();

    await MigrationRunner.runPending();

    final migrations = await MigrationRunner.getAppliedMigrations();

    print('');
    print('========================================');
    print('QUANTTORA MIGRATION STATUS');
    print('========================================');
    print('Applied migrations: ${migrations.length}');
    print('');

    for (final migration in migrations) {
      print(
        '${migration['version']} - '
        '${migration['name']} - '
        '${migration['applied_at']}',
      );
    }

    print('');
    print('MIGRATION TEST PASSED');
    print('========================================');
    print('');

    await Database.close();
  } catch (e, stackTrace) {
    print('');
    print('MIGRATION TEST FAILED');
    print('ERROR: $e');
    print('');
    print(stackTrace);

    await Database.close();
  }
}