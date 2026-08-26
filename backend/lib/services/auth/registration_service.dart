import 'package:backend/models/user.dart';
import 'package:backend/repositories/user_repository.dart';
import 'package:backend/services/auth/password_hash_service.dart';

class RegistrationService {
  RegistrationService._();

  static Future<User> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedDisplayName = displayName.trim();

    _validateEmail(normalizedEmail);
    _validateDisplayName(normalizedDisplayName);

    final existingUser =
        await UserRepository.findByEmail(normalizedEmail);

    if (existingUser != null) {
      throw StateError('A user with this email already exists.');
    }

    final passwordHash =
        await PasswordHashService.hash(password);

    return UserRepository.create(
      email: normalizedEmail,
      passwordHash: passwordHash,
      displayName: normalizedDisplayName,
    );
  }

  static void _validateEmail(String email) {
    if (email.isEmpty) {
      throw ArgumentError('Email cannot be empty.');
    }

    if (email.length > 320) {
      throw ArgumentError('Email is too long.');
    }

    final emailPattern = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailPattern.hasMatch(email)) {
      throw ArgumentError('Invalid email address.');
    }
  }

  static void _validateDisplayName(String displayName) {
    if (displayName.isEmpty) {
      throw ArgumentError('Display name cannot be empty.');
    }

    if (displayName.length > 100) {
      throw ArgumentError(
        'Display name cannot contain more than 100 characters.',
      );
    }
  }
}