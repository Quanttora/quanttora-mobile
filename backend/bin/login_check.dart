import 'package:backend/database/database.dart';
import 'package:backend/repositories/user_repository.dart';
import 'package:backend/services/auth/login_service.dart';
import 'package:backend/services/auth/registration_service.dart';

Future<void> main() async {
  const testEmail = 'login-test@quanttora.local';
  const testPassword = 'Quanttora-Login-Test-123!';
  const wrongPassword = 'Wrong-Login-Password-123!';

  try {
    await Database.initialize();

    print('');
    print('========================================');
    print('QUANTTORA LOGIN TEST');
    print('========================================');

    final existingUser =
        await UserRepository.findByEmail(testEmail);

    if (existingUser != null) {
      throw StateError(
        'Login test user already exists.',
      );
    }

    final registeredUser = await RegistrationService.register(
      email: testEmail,
      password: testPassword,
      displayName: 'Login Test User',
    );

    print('Test user created: ${registeredUser.id}');

    final loggedInUser = await LoginService.login(
      email: testEmail,
      password: testPassword,
    );

    print('Correct password login: true');
    print('Authenticated user ID: ${loggedInUser.id}');
    print('Last login updated: ${loggedInUser.lastLoginAt != null}');
    print(
      'Password hash exposed publicly: '
      '${loggedInUser.toPublicMap().containsKey('passwordHash')}',
    );

    if (loggedInUser.id != registeredUser.id) {
      throw StateError(
        'Login returned the wrong user.',
      );
    }

    if (loggedInUser.lastLoginAt == null) {
      throw StateError(
        'last_login_at was not updated.',
      );
    }

    if (loggedInUser.toPublicMap().containsKey('passwordHash')) {
      throw StateError(
        'Password hash was exposed publicly.',
      );
    }

    try {
      await LoginService.login(
        email: testEmail,
        password: wrongPassword,
      );

      throw StateError(
        'Wrong password was incorrectly accepted.',
      );
    } on LoginException {
      print('Wrong password rejected: true');
    }

    try {
      await LoginService.login(
        email: 'unknown-login-test@quanttora.local',
        password: testPassword,
      );

      throw StateError(
        'Unknown email was incorrectly accepted.',
      );
    } on LoginException {
      print('Unknown email rejected: true');
    }

    print('');
    print('LOGIN TEST PASSED');
    print('========================================');
    print('');
  } catch (e, stackTrace) {
    print('');
    print('LOGIN TEST FAILED');
    print('ERROR: $e');
    print('');
    print(stackTrace);
  } finally {
    await Database.close();
  }
}