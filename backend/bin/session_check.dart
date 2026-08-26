import 'package:backend/database/database.dart';
import 'package:backend/repositories/auth/session_repository.dart';
import 'package:backend/services/auth/session_service.dart';
import 'package:backend/services/auth/registration_service.dart';

Future<void> main() async {
  const testEmail = 'session-test@quanttora.local';
  const testPassword = 'Quanttora-Session-Test-123!';

  try {
    await Database.initialize();

    print('');
    print('========================================');
    print('QUANTTORA SESSION TEST');
    print('========================================');

    final user = await RegistrationService.register(
      email: testEmail,
      password: testPassword,
      displayName: 'Session Test User',
    );

    print('Test user created: ${user.id}');

    final session = await SessionService.createSession(
      userId: user.id,
    );

    print('Session created: ${session.id}');
    print('Token generated: ${session.token.isNotEmpty}');
    print('Token hash stored: ${session.tokenHash.isNotEmpty}');
    print('Expires in 30 days: '
        '${session.expiresAt.isAfter(DateTime.now().toUtc())}');

    final validated = await SessionService.validateToken(
      session.token,
    );

    if (validated == null) {
      throw StateError(
        'Valid session token was rejected.',
      );
    }

    if (validated.userId != user.id) {
      throw StateError(
        'Session returned the wrong user ID.',
      );
    }

    print('Valid token accepted: true');
    print('Correct user ID returned: true');

    final invalidToken = await SessionService.validateToken(
      'invalid-session-token',
    );

    if (invalidToken != null) {
      throw StateError(
        'Invalid session token was accepted.',
      );
    }

    print('Invalid token rejected: true');

    await SessionService.revokeToken(session.token);

    final revokedSession =
        await SessionService.validateToken(session.token);

    if (revokedSession != null) {
      throw StateError(
        'Revoked session token was accepted.',
      );
    }

    print('Revoked token rejected: true');

    final remainingSession =
        await SessionRepository.findActiveByTokenHash(
      session.tokenHash,
    );

    if (remainingSession != null) {
      throw StateError(
        'Revoked session is still marked active.',
      );
    }

    print('Revocation persisted: true');

    print('');
    print('SESSION TEST PASSED');
    print('========================================');
    print('');
  } catch (e, stackTrace) {
    print('');
    print('SESSION TEST FAILED');
    print('ERROR: $e');
    print('');
    print(stackTrace);
  } finally {
    await Database.close();
  }
}