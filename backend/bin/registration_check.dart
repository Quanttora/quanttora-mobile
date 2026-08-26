import 'package:backend/database/database.dart';
import 'package:backend/repositories/user_repository.dart';
import 'package:backend/services/auth/registration_service.dart';

Future<void> main() async {
  const testEmail = 'registration-test@quanttora.local';
  const testPassword = 'Quanttora-Registration-Test-123!';
  const testDisplayName = 'Registration Test User';

  try {
    await Database.initialize();

    print('');
    print('========================================');
    print('QUANTTORA REGISTRATION TEST');
    print('========================================');

    final existingUser =
        await UserRepository.findByEmail(testEmail);

    if (existingUser != null) {
      throw StateError(
        'Registration test user already exists.',
      );
    }

    final user = await RegistrationService.register(
      email: 'REGISTRATION-TEST@QUANTTORA.LOCAL',
      password: testPassword,
      displayName: testDisplayName,
    );

    print('User created: ${user.id}');
    print('Normalized email: ${user.email}');
    print('Display name: ${user.displayName}');
    print('Status: ${user.status}');
    print(
      'Public map contains password hash: '
      '${user.toPublicMap().containsKey('passwordHash')}',
    );

    if (user.email != testEmail) {
      throw StateError(
        'Email normalization failed.',
      );
    }

    if (user.toPublicMap().containsKey('passwordHash')) {
      throw StateError(
        'Password hash was exposed in public user data.',
      );
    }

    final storedUser =
        await UserRepository.findByEmail(testEmail);

    if (storedUser == null) {
      throw StateError(
        'Created user could not be retrieved.',
      );
    }

    if (storedUser.passwordHash.isEmpty) {
      throw StateError(
        'Password hash was not stored.',
      );
    }

    if (!storedUser.passwordHash.startsWith('argon2id\$v1\$')) {
      throw StateError(
        'Stored password is not an Argon2id v1 hash.',
      );
    }

    print('Email normalization: true');
    print('Password hash stored: true');
    print('Argon2id format verified: true');
    print('Password hash excluded from public map: true');

    print('');
    print('REGISTRATION TEST PASSED');
    print('========================================');
    print('');
  } catch (e, stackTrace) {
    print('');
    print('REGISTRATION TEST FAILED');
    print('ERROR: $e');
    print('');
    print(stackTrace);
  } finally {
    await Database.close();
  }
}