import 'package:backend/api/api_response.dart';
import 'package:backend/models/user.dart';
import 'package:backend/repositories/user_repository.dart';
import 'package:backend/services/auth/authentication_service.dart';
import 'package:backend/services/auth/supabase_auth_service.dart';
import 'package:shelf/shelf.dart';

class AuthMiddleware {
  AuthMiddleware._();

  static const String userContextKey = 'authenticated_user';
  static const String sessionContextKey = 'authenticated_session';

  static Middleware requireAuthentication() {
    return (Handler handler) {
      return (Request request) async {
        final authorization = request.headers['authorization'];

        if (authorization == null || authorization.trim().isEmpty) {
          return ApiResponse.error(
            statusCode: 401,
            code: 'AUTH_REQUIRED',
            message: 'Authentication is required.',
          );
        }

        final parts = authorization.trim().split(' ');

        if (parts.length != 2 ||
            parts[0].toLowerCase() != 'bearer' ||
            parts[1].trim().isEmpty) {
          return ApiResponse.error(
            statusCode: 401,
            code: 'INVALID_AUTH_HEADER',
            message: 'Invalid authentication header.',
          );
        }

        final token = parts[1].trim();

        // First try the existing Quanttora session system.
        final session = await AuthenticationService.authenticateToken(token);

        if (session != null) {
          final user = await UserRepository.findById(session.userId);

          if (user == null || !user.isActive) {
            return ApiResponse.error(
              statusCode: 401,
              code: 'INVALID_USER',
              message: 'Authentication session is invalid.',
            );
          }

          final updatedRequest = request.change(
            context: {userContextKey: user, sessionContextKey: session},
          );

          return handler(updatedRequest);
        }

        // If it is not a Quanttora session token,
        // try the Supabase access token.
        try {
          final supabaseUser =
              await SupabaseAuthService.authenticateAccessToken(token);

          if (supabaseUser == null) {
            return ApiResponse.error(
              statusCode: 401,
              code: 'INVALID_SESSION',
              message: 'Authentication session is invalid or expired.',
            );
          }

          final updatedRequest = request.change(
            context: {userContextKey: supabaseUser},
          );

          return handler(updatedRequest);
        } catch (_) {
          return ApiResponse.error(
            statusCode: 401,
            code: 'AUTHENTICATION_FAILED',
            message: 'Authentication could not be verified.',
          );
        }
      };
    };
  }

  static User? getUser(Request request) {
    final value = request.context[userContextKey];

    if (value is User) {
      return value;
    }

    return null;
  }

  static int? getUserId(Request request) {
    final user = getUser(request);

    return user?.id;
  }
}
