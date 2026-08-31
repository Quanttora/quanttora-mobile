import 'dart:io';

import 'package:backend/database/database.dart';
import 'package:backend/database/migration_runner.dart';
import 'package:backend/middleware/auth_middleware.dart';
import 'package:backend/routes/auth_routes.dart';
import 'package:backend/routes/broker_routes.dart';
import 'package:backend/routes/market_routes.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

Future<void> main() async {
  // Initialize the database before registering the server.
  await Database.initialize();

  // Run any pending database migrations before starting the server.
  await MigrationRunner.runPending();

  final router = Router();

  router.get('/health', (Request request) {
    return Response.ok('Backend Running ðŸš€');
  });

  // Authentication routes.
  router.mount('/auth/', AuthRoutes().router.call);

  // Broker routes require authentication.
  final brokerHandler = Pipeline()
      .addMiddleware(AuthMiddleware.requireAuthentication())
      .addHandler(BrokerRoutes().router.call);

  router.mount('/broker/', brokerHandler);

  // Market routes.
  router.mount('/market/', MarketRoutes().router.call);

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);

  await io.serve(handler, InternetAddress.anyIPv4, 8080);

  print('');
  print('========================================');
  print('ðŸš€ Quanttora Backend Started');
  print('ðŸŒ http://0.0.0.0:8080');
  print('========================================');
}
