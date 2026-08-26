import 'package:backend/models/user.dart';
import 'package:backend/repositories/user_repository.dart';
import 'package:backend/services/auth/password_hash_service.dart';

class LoginService {
  LoginService._();

  static Future<User> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      throw const LoginException();
    }

    if (password.isEmpty) {
      throw const LoginException();
    }

    final user = await UserRepository.findByEmail(normalizedEmail);

    if (user == null) {
      throw const LoginException();
    }

    if (!user.isActive) {
      throw const LoginException();
    }

    final passwordMatches = await PasswordHashService.verify(
      password,
      user.passwordHash,
    );

    if (!passwordMatches) {
      throw const LoginException();
    }

    await UserRepository.updateLastLogin(user.id);

    final updatedUser = await UserRepository.findById(user.id);

    if (updatedUser == null) {
      throw StateError(
        'Authenticated user could not be loaded after login.',
      );
    }

    return updatedUser;
  }
}

class LoginException implements Exception {
  const LoginException();

  @override
  String toString() => 'Invalid email or password.';
}