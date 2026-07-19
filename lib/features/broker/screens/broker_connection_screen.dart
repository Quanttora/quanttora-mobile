import 'dart:convert';
import 'dart:io';

import 'package:backend/integrations/upstox/upstox_auth_service.dart';
import 'package:backend/models/broker_connection.dart';
import 'package:backend/services/broker_connection_repository.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class AuthRoutes {
  final UpstoxAuthService _upstox = UpstoxAuthService();
  final BrokerConnectionRepository _repository =
      BrokerConnectionRepository();

  Router get router {
    final router = Router();

    router.get('/upstox/login', (Request request) {
      return Response.found(
        _upstox.getLoginUrl(),
      );
    });

    router.get('/upstox/callback', (Request request) async {
      final code = request.requestedUri.queryParameters['code'];

      if (code == null || code.isEmpty) {
        return Response(
          HttpStatus.badRequest,
          body: 'Authorization Code Missing',
        );
      }

      try {
        final token = await _upstox.exchangeCode(code: code);

        final accessToken = token['access_token'] ?? '';

        final profileResponse = await http.get(
          Uri.parse(
            'https://api.upstox.com/v2/user/profile',
          ),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (profileResponse.statusCode != 200) {
          return Response.internalServerError(
            body: profileResponse.body,
          );
        }

        final profile =
            jsonDecode(profileResponse.body)['data'];

        final connection = BrokerConnection(
          broker: 'Upstox',
          userId: profile['user_id'].toString(),
          userName: profile['user_name'].toString(),
          email: profile['email'].toString(),
          accessToken: accessToken,
          extendedToken: token['extended_token']?.toString() ?? '',
        );

        _repository.save(connection);

        print('');
        print('==============================');
        print('UPSTOX CONNECTED');
        print(connection.userName);
        print(connection.email);
        print('==============================');
        print('');

        return Response.found(
          'http://localhost:3000/broker-connected',
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