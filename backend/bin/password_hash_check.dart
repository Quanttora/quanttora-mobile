import 'package:backend/services/auth/password_hash_service.dart';

Future<void> main() async {
  const password = 'Quanttora-Test-Password-123!';

  try {
    print('');
    print('========================================');
    print('QUANTTORA PASSWORD HASH TEST');
    print('========================================');

    final hash = await PasswordHashService.hash(password);

    print('Hash generated: ${hash.isNotEmpty}');
    print('Password stored directly: false');

    final correctPasswordResult =
        await PasswordHashService.verify(password, hash);

    final incorrectPasswordResult =
        await PasswordHashService.verify(
      'Wrong-Password-123!',
      hash,
    );

    print('Correct password verified: $correctPasswordResult');
    print('Incorrect password rejected: ${!incorrectPasswordResult}');

    if (!correctPasswordResult || incorrectPasswordResult) {
      throw StateError('Password hashing verification failed.');
    }

    print('');
    print('PASSWORD HASH TEST PASSED');
    print('========================================');
    print('');

    print('Generated hash: $hash');
    print('');
  } catch (e, stackTrace) {
    print('');
    print('PASSWORD HASH TEST FAILED');
    print('ERROR: $e');
    print('');
    print(stackTrace);
  }
}