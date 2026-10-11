import 'dart:io';

import 'package:backend/database/database.dart';
import 'package:backend/middleware/auth_middleware.dart';
import 'package:backend/routes/broker_routes.dart';
import 'package:backend/routes/market_routes.dart';
import 'package:backend/routes/risk_guard/risk_guard_routes.dart';
import 'package:backend/routes/zerodha_auth_routes.dart';
import 'package:backend/services/broker_startup_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

Future<void> main() async {
  await Database.initialize();

  final router = Router();

  router.get('/health', (Request request) {
    return Response.ok(
      'Backend Running',
      headers: const {
        'Content-Type': 'text/plain',
      },
    );
  });

  /*
   * IMPORTANT:
   *
   * ZerodhaAuthRoutes contains the complete authentication router:
   *
   *   /login
   *   /register
   *   /logout
   *   /me
   *   /upstox/login
   *   /upstox/callback
   *   /zerodha/login
   *   /zerodha/callback
   *
   * Therefore it MUST be mounted at /auth/.
   *
   * This makes:
   *
   *   /auth/login
   *   /auth/zerodha/login
   *   /auth/zerodha/callback
   *
   * resolve to the correct handlers.
   */
  router.mount(
    '/auth/',
    ZerodhaAuthRoutes().router.call,
  );

  /*
   * Broker routes require an authenticated Quanttora user.
   */
  final brokerHandler = Pipeline()
      .addMiddleware(
        AuthMiddleware.requireAuthentication(),
      )
      .addHandler(
        BrokerRoutes().router.call,
      );

  router.mount(
    '/broker/',
    brokerHandler,
  );

  /*
   * Market routes require an authenticated Quanttora user.
   */
  final marketHandler = Pipeline()
      .addMiddleware(
        AuthMiddleware.requireAuthentication(),
      )
      .addHandler(
        MarketRoutes().router.call,
      );

  router.mount(
    '/market/',
    marketHandler,
  );

  /*
   * Risk Guard routes require an authenticated Quanttora user.
   */
  final riskGuardHandler = Pipeline()
      .addMiddleware(
        AuthMiddleware.requireAuthentication(),
      )
      .addHandler(
        RiskGuardRoutes().router.call,
      );

  router.mount(
    '/risk-guard/',
    riskGuardHandler,
  );

  /*
   * Restore the last valid broker session when the backend starts.
   */
  await BrokerStartupService.instance.restore();

  /*
   * Global request logging.
   */
  final handler = Pipeline()
      .addMiddleware(
        logRequests(),
      )
      .addHandler(
        router.call,
      );

  await io.serve(
    handler,
    InternetAddress.anyIPv4,
    8080,
  );

  print('');
  print('========================================');
  print('Quanttora Backend Started');
  print('http://0.0.0.0:8080');
  print('========================================');
}