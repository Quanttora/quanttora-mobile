import 'dart:io';

import 'package:backend/database/database.dart';
import 'package:backend/middleware/auth_middleware.dart';
import 'package:backend/routes/auth_routes.dart';
import 'package:backend/routes/broker_routes.dart';
import 'package:backend/routes/market_routes.dart';
import 'package:backend/services/broker_startup_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

Future<void> main() async {
  await Database.initialize();

  final router = Router();

  router.get('/health', (Request request) {
    return Response.ok(
      'Backend Running 🚀',
      headers: const {
        'Content-Type': 'text/plain',
      },
    );
  });

  router.mount('/auth/', AuthRoutes().router.call);

  final brokerHandler = Pipeline()
      .addMiddleware(
        AuthMiddleware.requireAuthentication(),
      )
      .addHandler(
        BrokerRoutes().router.call,
      );

  router.mount('/broker/', brokerHandler);

  router.mount(
    '/market/',
    MarketRoutes().router.call,
  );

  // Restore persisted broker connections and reconnect
  // the real Upstox market feed before accepting traffic.
  await BrokerStartupService.instance.restore();

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);

  await io.serve(
    handler,
    InternetAddress.anyIPv4,
    8080,
  );

  print('');
  print('========================================');
  print('🚀 Quanttora Backend Started');
  print('🌐 http://0.0.0.0:8080');
  print('========================================');
}