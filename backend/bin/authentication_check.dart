import 'package:backend/database/database.dart';
import 'package:backend/repositories/auth/session_repository.dart';
import 'package:backend/repositories/user_repository.dart';
import 'package:backend/services/auth/authentication_service.dart';
import 'package:backend/services/auth/registration_service.dart';

Future<void> main() async {
  const testEmail = 'authentication-test@quanttora.local';
  const testPassword = 'Quanttora-Authentication-Test-123!';

  try {
    await Database.initialize();

    print('');
    print('========================================');
    print('QUANTTORA AUTHENTICATION TEST');
    print('========================================');

    final existingUser =
        await UserRepository.findByEmail(testEmail);

    if (existingUser != null) {
      throw StateError(
        'Authentication test user already exists.',
      );
    }

    final registeredUser =
        await RegistrationService.register(
      email: testEmail,
      password: testPassword,
      displayName: 'Authentication Test User',
    );

    print('Test user created: ${registeredUser.id}');

    final result = await AuthenticationService.login(
      email: testEmail,
      password: testPassword,
    );

    print('Authentication login: true');
    print('Authenticated user ID: ${result.user.id}');
    print('Session created: ${result.session.id}');
    print('Session token generated: '
        '${result.session.token.isNotEmpty}');

    if (result.user.id != registeredUser.id) {
      throw StateError(
        'Authentication returned the wrong user.',
      );
    }

    final authenticatedSession =
        await AuthenticationService.authenticateToken(
      result.session.token,
    );

    if (authenticatedSession == null) {
      throw StateError(
        'Valid authentication token was rejected.',
      );
    }

    if (authenticatedSession.userId != registeredUser.id) {
      throw StateError(
        'Authenticated token returned the wrong user.',
      );
    }

    print('Token authentication: true');
    print('Token maps to correct user: true');

    await AuthenticationService.logout(
      result.session.token,
    );

    final afterLogout =
        await AuthenticationService.authenticateToken(
      result.session.token,
    );

    if (afterLogout != null) {
      throw StateError(
        'Logged-out token was still accepted.',
      );
    }

    print('Logout: true');
    print('Logged-out token rejected: true');

    final storedSession =
        await SessionRepository.findActiveByTokenHash(
      result.session.tokenHash,
    );

    if (storedSession != null) {
      throw StateError(
        'Logged-out session is still active.',
      );
    }

    final storedUser =
        await UserRepository.findByEmail(testEmail);

    if (storedUser == null) {
      throw StateError(
        'Test user could not be loaded.',
      );
    }

    if (storedUser.toPublicMap().containsKey('passwordHash')) {
      throw StateError(
        'Password hash exposed in public user data.',
      );
    }

    print('Session revocation persisted: true');
    print('Password hash excluded from public data: true');

    print('');
    print('AUTHENTICATION TEST PASSED');
    print('========================================');
    print('');
  } catch (e, stackTrace) {
    print('');
    print('AUTHENTICATION TEST FAILED');
    print('ERROR: $e');
    print('');
    print(stackTrace);
  } finally {
    await Database.close();
  }
}