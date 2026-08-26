import 'package:backend/database/database.dart';
import 'package:backend/repositories/user_repository.dart';

Future<void> main() async {
  try {
    await Database.initialize();

    print('');
    print('========================================');
    print('QUANTTORA USER REPOSITORY TEST');
    print('========================================');

    const testEmail = 'repository-test@quanttora.local';

    final existingUser = await UserRepository.findByEmail(testEmail);

    if (existingUser != null) {
      throw StateError(
        'Test user already exists. '
        'Remove it from the database before running this test again.',
      );
    }

    final user = await UserRepository.create(
      email: testEmail,
      passwordHash: 'test-hash-not-a-real-password',
      displayName: 'Repository Test User',
    );

    print('User created: ${user.id}');
    print('Email: ${user.email}');
    print('Display name: ${user.displayName}');
    print('Status: ${user.status}');
    print('Public map contains password hash: '
        '${user.toPublicMap().containsKey('passwordHash')}');

    final foundById = await UserRepository.findById(user.id);

    if (foundById == null) {
      throw StateError('User could not be found by ID.');
    }

    final foundByEmail =
        await UserRepository.findByEmail('REPOSITORY-TEST@QUANTTORA.LOCAL');

    if (foundByEmail == null) {
      throw StateError('User could not be found by email.');
    }

    if (foundById.id != user.id) {
      throw StateError('ID lookup returned the wrong user.');
    }

    if (foundByEmail.id != user.id) {
      throw StateError('Email lookup returned the wrong user.');
    }

    if (user.toPublicMap().containsKey('passwordHash')) {
      throw StateError(
        'Public user representation exposed password hash.',
      );
    }

    print('Find by ID: true');
    print('Find by email: true');
    print('Case-insensitive email lookup: true');
    print('Password hash excluded from public map: true');

    print('');
    print('USER REPOSITORY TEST PASSED');
    print('========================================');
    print('');

    await Database.close();
  } catch (e, stackTrace) {
    print('');
    print('USER REPOSITORY TEST FAILED');
    print('ERROR: $e');
    print('');
    print(stackTrace);

    await Database.close();
  }
}