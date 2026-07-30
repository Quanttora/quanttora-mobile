import 'dart:io';

import 'package:backend/generated/market_data_v3.pb.dart';
import 'package:backend/routes/auth_routes.dart';
import 'package:backend/routes/broker_routes.dart';
import 'package:backend/routes/market_routes.dart';
import 'package:backend/services/market_feed_processor.dart';
import 'package:backend/services/upstox_market_feed.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  final router = Router();

  router.get('/health', (_) {
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

  router.mount(
    '/market/',
    MarketRoutes().router.call,
  );

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);

  final server = await io.serve(
    handler,
    InternetAddress.anyIPv4,
    8080,
  );

  UpstoxMarketFeed.instance.listen(
    (FeedResponse response) {
      MarketFeedProcessor.instance.process(response);
    },
  );

  ProcessSignal.sigint.watch().listen((_) async {
    await UpstoxMarketFeed.instance.disconnect();
    await server.close(force: true);
    exit(0);
  });

  print('');
  print('========================================');
  print('🚀 Quanttora Backend Started');
  print('🌐 http://${server.address.host}:${server.port}');
  print('========================================');
}