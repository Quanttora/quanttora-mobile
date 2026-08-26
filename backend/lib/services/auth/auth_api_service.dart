import 'package:backend/services/auth/authentication_service.dart';
import 'package:backend/services/auth/registration_service.dart';

class AuthApiService {
  AuthApiService._();

  static Future<AuthenticationResult> login({
    required String email,
    required String password,
  }) {
    return AuthenticationService.login(
      email: email,
      password: password,
    );
  }

  static Future<RegistrationResult> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final user = await RegistrationService.register(
      email: email,
      password: password,
      displayName: displayName,
    );

    return RegistrationResult(userId: user.id);
  }

  static Future<void> logout(String token) {
    return AuthenticationService.logout(token);
  }
}

class RegistrationResult {
  const RegistrationResult({
    required this.userId,
  });

  final int userId;
}