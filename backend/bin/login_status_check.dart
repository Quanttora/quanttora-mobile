import 'package:backend/database/database.dart';
import 'package:backend/repositories/user_repository.dart';
import 'package:backend/services/auth/login_service.dart';
import 'package:backend/services/auth/registration_service.dart';
import 'package:postgres/postgres.dart';

Future<void> main() async {
  const testEmail = 'login-status-test@quanttora.local';
  const testPassword = 'Quanttora-Status-Test-123!';

  try {
    await Database.initialize();

    print('');
    print('========================================');
    print('QUANTTORA LOGIN STATUS TEST');
    print('========================================');

    final existingUser =
        await UserRepository.findByEmail(testEmail);

    if (existingUser != null) {
      throw StateError(
        'Login status test user already exists.',
      );
    }

    final user = await RegistrationService.register(
      email: testEmail,
      password: testPassword,
      displayName: 'Login Status Test User',
    );

    print('Test user created: ${user.id}');

    await Database.execute(
      Sql.named('''
        UPDATE users
        SET status = @status,
            updated_at = NOW()
        WHERE id = @id
      '''),
      parameters: {
        'status': 'suspended',
        'id': user.id,
      },
    );

    try {
      await LoginService.login(
        email: testEmail,
        password: testPassword,
      );

      throw StateError(
        'Suspended user was incorrectly allowed to log in.',
      );
    } on LoginException {
      print('Suspended user rejected: true');
    }

    await Database.execute(
      Sql.named('''
        UPDATE users
        SET status = @status,
            updated_at = NOW()
        WHERE id = @id
      '''),
      parameters: {
        'status': 'disabled',
        'id': user.id,
      },
    );

    try {
      await LoginService.login(
        email: testEmail,
        password: testPassword,
      );

      throw StateError(
        'Disabled user was incorrectly allowed to log in.',
      );
    } on LoginException {
      print('Disabled user rejected: true');
    }

    print('');
    print('LOGIN STATUS TEST PASSED');
    print('========================================');
    print('');
  } catch (e, stackTrace) {
    print('');
    print('LOGIN STATUS TEST FAILED');
    print('ERROR: $e');
    print('');
    print(stackTrace);
  } finally {
    await Database.close();
  }
}