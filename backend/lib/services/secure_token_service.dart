import 'dart:convert';

import 'package:backend/core/config/app_config.dart';
import 'package:cryptography/cryptography.dart';

class SecureTokenService {
  SecureTokenService._();

  static final SecureTokenService instance = SecureTokenService._();

  final AesGcm _algorithm = AesGcm.with256bits();

  late final SecretKey _key = _loadKey();

  SecretKey _loadKey() {
    const keyName = 'BROKER_TOKEN_ENCRYPTION_KEY';
    final value = _envValue(keyName);

    if (value.isEmpty) {
      throw StateError(
        '$keyName must be provided through the environment.',
      );
    }

    final keyBytes = base64Decode(value);

    if (keyBytes.length != 32) {
      throw StateError(
        '$keyName must decode to exactly 32 bytes.',
      );
    }

    return SecretKey(keyBytes);
  }

  String _envValue(String key) {
    if (key == 'BROKER_TOKEN_ENCRYPTION_KEY') {
      return AppConfig.brokerTokenEncryptionKey;
    }

    return '';
  }

  bool isEncrypted(String value) {
    if (value.isEmpty) {
      return false;
    }

    try {
      final decoded = utf8.decode(base64Decode(value));
      final payload = jsonDecode(decoded);

      if (payload is! Map<String, dynamic>) {
        return false;
      }

      return payload['v'] == 1 &&
          payload['nonce'] is String &&
          payload['ciphertext'] is String &&
          payload['mac'] is String;
    } catch (_) {
      return false;
    }
  }

  Future<String> encrypt(String plaintext) async {
    if (plaintext.isEmpty) {
      return plaintext;
    }

    if (isEncrypted(plaintext)) {
      return plaintext;
    }

    final nonce = _algorithm.newNonce();

    final secretBox = await _algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: _key,
      nonce: nonce,
    );

    final payload = <String, dynamic>{
      'v': 1,
      'nonce': base64Encode(secretBox.nonce),
      'ciphertext': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
    };

    return base64Encode(
      utf8.encode(jsonEncode(payload)),
    );
  }

  Future<String> decrypt(String encrypted) async {
    if (encrypted.isEmpty) {
      return encrypted;
    }

    // Legacy plaintext tokens are returned as-is so they
    // can be migrated to encrypted storage by the repository.
    if (!isEncrypted(encrypted)) {
      return encrypted;
    }

    try {
      final decoded = utf8.decode(base64Decode(encrypted));
      final payload = jsonDecode(decoded) as Map<String, dynamic>;

      if (payload['v'] != 1) {
        throw StateError('Unsupported encrypted token version.');
      }

      final secretBox = SecretBox(
        base64Decode(payload['ciphertext'] as String),
        nonce: base64Decode(payload['nonce'] as String),
        mac: Mac(
          base64Decode(payload['mac'] as String),
        ),
      );

      final clearText = await _algorithm.decrypt(
        secretBox,
        secretKey: _key,
      );

      return utf8.decode(clearText);
    } catch (error) {
      throw StateError(
        'Unable to decrypt broker token: $error',
      );
    }
  }
}