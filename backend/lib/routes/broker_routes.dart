import 'dart:convert';

import 'package:backend/integrations/upstox/upstox_broker_service.dart';
import 'package:backend/services/broker_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class BrokerRoutes {
  final BrokerService _brokerService = BrokerService.instance;
  final UpstoxBrokerService _upstoxBrokerService =
      UpstoxBrokerService();

  Router get router {
    final router = Router();

    router.get('/status', (Request request) {
      if (!_brokerService.isConnected) {
        return Response.ok(
          jsonEncode({
            'connected': false,
          }),
          headers: {
            'Content-Type': 'application/json',
          },
        );
      }

      final session = _brokerService.session!;

      return Response.ok(
        jsonEncode({
          'connected': true,
          'broker': session.broker,
          'userId': session.userId,
          'userName': session.userName,
          'email': session.email,
          'connectedAt': session.connectedAt.toIso8601String(),
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    });

    router.get('/funds', (Request request) async {
      if (!_brokerService.isConnected) {
        return Response.forbidden('Broker not connected');
      }

      final data = await _upstoxBrokerService.getFunds(
        _brokerService.session!.accessToken,
      );

      return Response.ok(
        jsonEncode(data),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    });

    return router;
  }
}