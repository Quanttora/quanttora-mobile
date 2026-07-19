import 'dart:convert';
import 'dart:io';

import 'package:backend/integrations/upstox/upstox_auth_service.dart';
import 'package:backend/models/broker_session.dart';
import 'package:backend/services/broker_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class AuthRoutes {
  final UpstoxAuthService _upstox = UpstoxAuthService();
  final BrokerService _brokerService = BrokerService.instance;

  Router get router {
    final router = Router();

    router.get('/upstox/login', (Request request) {
      final loginUrl = _upstox.getLoginUrl();

      print('');
      print('========================================');
      print('Opening Upstox Login');
      print(loginUrl);
      print('========================================');
      print('');

      return Response.found(loginUrl);
    });

    router.get('/upstox/callback', (Request request) async {
      final code = request.requestedUri.queryParameters['code'];

      if (code == null || code.isEmpty) {
        return Response.badRequest(
          body: 'Authorization code not received.',
        );
      }

      try {
        final token = await _upstox.exchangeCode(
          code: code,
        );

        final accessToken = token['access_token'];

        if (accessToken == null) {
          return Response.internalServerError(
            body: 'Access token not received.',
          );
        }

        final profileRequest = await HttpClient().getUrl(
          Uri.parse(
            'https://api.upstox.com/v2/user/profile',
          ),
        );

        profileRequest.headers.set(
          HttpHeaders.authorizationHeader,
          'Bearer $accessToken',
        );

        profileRequest.headers.set(
          HttpHeaders.acceptHeader,
          'application/json',
        );

        final profileResponse = await profileRequest.close();

        final profileBody =
            await utf8.decoder.bind(profileResponse).join();

        if (profileResponse.statusCode != 200) {
          return Response.internalServerError(
            body: profileBody,
          );
        }

        final profile =
            jsonDecode(profileBody) as Map<String, dynamic>;

        final data =
            profile['data'] as Map<String, dynamic>;

        final session = BrokerSession(
          broker: 'Upstox',
          userId: data['user_id'] ?? '',
          userName: data['user_name'] ?? '',
          email: data['email'] ?? '',
          accessToken: accessToken,
          connectedAt: DateTime.now(),
        );

        _brokerService.connect(session);

        print('');
        print('========================================');
        print('BROKER CONNECTED');
        print('========================================');
        print('Broker : ${session.broker}');
        print('User   : ${session.userName}');
        print('ID     : ${session.userId}');
        print('Email  : ${session.email}');
        print('========================================');
        print('');

        return Response.found(
          Uri.parse(
            'quanttora://broker-connected',
          ),
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