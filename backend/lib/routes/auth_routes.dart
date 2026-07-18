import 'dart:io';

import 'package:backend/integrations/upstox/upstox_auth_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class AuthRoutes {
  final UpstoxAuthService _upstox = UpstoxAuthService();

  Router get router {
    final router = Router();

    /// Redirect to Upstox Login
    router.get('/upstox/login', (Request request) {
      final loginUrl = _upstox.getLoginUrl();

      print('');
      print('===============================');
      print('Redirecting to Upstox Login');
      print(loginUrl);
      print('===============================');
      print('');

      return Response.found(loginUrl);
    });

    /// OAuth Callback
    router.get('/upstox/callback', (Request request) async {
      final code = request.requestedUri.queryParameters['code'];

      if (code == null || code.isEmpty) {
        return Response(
          HttpStatus.badRequest,
          body: 'Authorization code not received.',
        );
      }

      try {
        final token = await _upstox.exchangeCode(
          code: code,
        );

        return Response.ok(
          token.toString(),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
          },
        );
      } catch (e) {
        return Response.internalServerError(
          body: e.toString(),
        );
      }
    });

    return router;
  }
}