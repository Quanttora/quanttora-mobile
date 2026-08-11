import 'dart:convert';
import 'dart:io';

import 'package:backend/integrations/upstox/upstox_auth_service.dart';
import 'package:backend/models/broker_connection.dart';
import 'package:backend/models/broker_session.dart';
import 'package:backend/services/broker_connection_repository.dart';
import 'package:backend/services/broker_service.dart';
import 'package:backend/services/upstox_market_feed.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class AuthRoutes {
  final UpstoxAuthService _upstox = UpstoxAuthService();

  final BrokerConnectionRepository _repository =
      BrokerConnectionRepository();

  final BrokerService _brokerService =
      BrokerService.instance;

  final UpstoxMarketFeed _marketFeed =
      UpstoxMarketFeed.instance;

  static const List<String> _marketInstruments = [
    // MAIN INDICES
    'NSE_INDEX|Nifty 50',
    'NSE_INDEX|Nifty Bank',
    'BSE_INDEX|SENSEX',
    'NSE_INDEX|India VIX',

    // SECTOR INDICES
    'NSE_INDEX|Nifty Auto',
    'NSE_INDEX|Nifty FMCG',
    'NSE_INDEX|Nifty IT',
    'NSE_INDEX|Nifty Metal',
    'NSE_INDEX|Nifty Pharma',
    'NSE_INDEX|Nifty PSU Bank',
    'NSE_INDEX|Nifty Realty',

    // WATCHLIST EQUITIES
    'NSE_EQ|INE002A01018', // RELIANCE
    'NSE_EQ|INE467B01029', // TCS
    'NSE_EQ|INE040A01034', // HDFCBANK
    'NSE_EQ|INE009A01021', // INFY
    'NSE_EQ|INE090A01021', // ICICIBANK
    'NSE_EQ|INE062A01020', // SBIN
    'NSE_EQ|INE397D01024', // BHARTIARTL
    'NSE_EQ|INE154A01025', // ITC
  ];

  Router get router {
    final router = Router();

    router.get('/upstox/login', (Request request) {
      return Response.found(
        _upstox.getLoginUrl(),
      );
    });

    router.get('/upstox/callback', (
      Request request,
    ) async {
      final code =
          request.requestedUri.queryParameters['code'];

      if (code == null || code.isEmpty) {
        return Response(
          HttpStatus.badRequest,
          body: 'Authorization Code Missing',
        );
      }

      try {
        final token = await _upstox.exchangeCode(
          code: code,
        );

        final accessToken =
            token['access_token']?.toString() ?? '';

        final refreshToken =
            token['refresh_token']?.toString();

        final profileResponse = await http.get(
          Uri.parse(
            'https://api.upstox.com/v2/user/profile',
          ),
          headers: {
            'Accept': 'application/json',
            'Authorization':
                'Bearer $accessToken',
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
          userName:
              profile['user_name'].toString(),
          email: profile['email'].toString(),
          accessToken: accessToken,
          extendedToken:
              token['extended_token']
                      ?.toString() ??
                  '',
        );

        _repository.save(connection);

        _brokerService.connect(
          BrokerSession(
            broker: connection.broker,
            userId: connection.userId,
            userName: connection.userName,
            email: connection.email,
            accessToken: accessToken,
            refreshToken: refreshToken,
            connectedAt: DateTime.now(),
          ),
        );

        await _marketFeed.connect();

        await _marketFeed.subscribeMany(
          _marketInstruments,
        );

        print('');
        print(
          '==============================',
        );
        print('UPSTOX CONNECTED');
        print(connection.userName);
        print(connection.email);
        print(
          'MARKET INSTRUMENTS SUBSCRIBED: '
          '${_marketInstruments.length}',
        );
        print(
          '==============================',
        );
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