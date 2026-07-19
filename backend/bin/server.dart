import 'dart:io';

import 'package:backend/routes/auth_routes.dart';
import 'package:backend/routes/broker_routes.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  final router = Router();

  router.get('/health', (Request request) {
    return Response.ok('Backend Running 🚀');
  });

  router.mount(
    '/auth/',
    AuthRoutes().router.call,
  );

  router.mount(
    '/broker/',
    BrokerRoutes().router.call,
  );

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);

  final server = await io.serve(
    handler,
    InternetAddress.anyIPv4,
    8080,
  );

  print('');
  print('========================================');
  print('🚀 Quanttora Backend Started');
  print('🌐 http://${server.address.host}:${server.port}');
  print('========================================');
}