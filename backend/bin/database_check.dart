import 'package:backend/database/database.dart';

Future<void> main() async {
  try {
    await Database.initialize();

    final result = await Database.execute(
      'SELECT current_database(), current_user',
    );

    final row = result.first;

    print('');
    print('DATABASE CONNECTION TEST PASSED');
    print('Database: ${row[0]}');
    print('User: ${row[1]}');
    print('');

    await Database.close();
  } catch (e, stackTrace) {
    print('');
    print('DATABASE CONNECTION TEST FAILED');
    print('ERROR: $e');
    print('');
    print(stackTrace);

    await Database.close();
  }
}