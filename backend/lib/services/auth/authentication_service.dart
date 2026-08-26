import 'package:backend/models/user.dart';
import 'package:backend/services/auth/login_service.dart';
import 'package:backend/services/auth/session_service.dart';

class AuthenticationResult {
  const AuthenticationResult({
    required this.user,
    required this.session,
  });

  final User user;
  final SessionWithToken session;
}

class AuthenticationService {
  AuthenticationService._();

  static Future<AuthenticationResult> login({
    required String email,
    required String password,
  }) async {
    final user = await LoginService.login(
      email: email,
      password: password,
    );

    final session = await SessionService.createSession(
      userId: user.id,
    );

    return AuthenticationResult(
      user: user,
      session: session,
    );
  }

  static Future<SessionWithToken?> authenticateToken(
    String token,
  ) async {
    final session = await SessionService.validateToken(token);

    if (session == null) {
      return null;
    }

    return SessionWithToken(
      session: session,
      token: token,
    );
  }

  static Future<void> logout(String token) async {
    await SessionService.revokeToken(token);
  }

  static Future<void> logoutAll(int userId) async {
    await SessionService.revokeAllSessions(userId);
  }
}