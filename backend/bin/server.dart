import 'dart:io';

import 'package:backend/routes/auth_routes.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

Future<void> main() async {
  final router = Router();

  // Health Check
  router.get('/health', (Request request) {
    return Response.ok(
      'Quanttora Backend Running 🚀',
      headers: {
        HttpHeaders.contentTypeHeader: 'text/plain',
      },
    );
  });

  // Auth Routes
  router.mount('/auth/', AuthRoutes().router);

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router);

  final server = await io.serve(
    handler,
    InternetAddress.anyIPv4,
    8080,
  );

  print('');
  print('========================================');
  print('🚀 Quanttora Backend Started');
  print('🌐 http://localhost:${server.port}');
  print('========================================');
  print('');
}