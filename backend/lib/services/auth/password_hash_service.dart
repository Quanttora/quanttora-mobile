import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

class PasswordHashService {
  PasswordHashService._();

  static final Argon2id _argon2 = Argon2id(
    memory: 64 * 1024,
    parallelism: 2,
    iterations: 3,
    hashLength: 32,
  );

  static const int _saltLength = 16;

  static Future<String> hash(String password) async {
    _validatePassword(password);

    final random = Random.secure();
    final salt = List<int>.generate(
      _saltLength,
      (_) => random.nextInt(256),
    );

    final secretKey = await _argon2.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );

    final hashBytes = await secretKey.extractBytes();

    return [
      'argon2id',
      'v1',
      base64UrlEncode(salt),
      base64UrlEncode(hashBytes),
    ].join('\$');
  }

  static Future<bool> verify(
    String password,
    String storedHash,
  ) async {
    _validatePassword(password);

    final parts = storedHash.split('\$');

    if (parts.length != 4) {
      return false;
    }

    if (parts[0] != 'argon2id' || parts[1] != 'v1') {
      return false;
    }

    try {
      final salt = base64Url.decode(parts[2]);
      final expectedHash = base64Url.decode(parts[3]);

      final secretKey = await _argon2.deriveKeyFromPassword(
        password: password,
        nonce: salt,
      );

      final actualHash = await secretKey.extractBytes();

      return _constantTimeEquals(actualHash, expectedHash);
    } catch (_) {
      return false;
    }
  }

  static void _validatePassword(String password) {
    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty.');
    }

    if (password.length < 8) {
      throw ArgumentError(
        'Password must contain at least 8 characters.',
      );
    }

    if (password.length > 128) {
      throw ArgumentError(
        'Password cannot contain more than 128 characters.',
      );
    }
  }

  static bool _constantTimeEquals(
    List<int> a,
    List<int> b,
  ) {
    if (a.length != b.length) {
      return false;
    }

    var difference = 0;

    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }

    return difference == 0;
  }
}