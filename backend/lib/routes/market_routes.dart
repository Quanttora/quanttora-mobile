import 'dart:convert';

import 'package:backend/models/market_tick.dart';
import 'package:backend/services/market_store.dart';
import 'package:backend/services/upstox_market_feed.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class MarketRoutes {
  final Router router = Router()
    ..get('/status', _status)
    ..get('/dashboard', _dashboard)
    ..get('/quotes', _quotes)
    ..get('/quote/<instrumentKey>', _quote);

  static const Map<String, String> _dashboardSymbols = {
    'nifty': 'NSE_INDEX|Nifty 50',
    'bankNifty': 'NSE_INDEX|Nifty Bank',
    'sensex': 'BSE_INDEX|SENSEX',
    'indiaVix': 'NSE_INDEX|India VIX',
  };

  static Response _status(Request request) {
    return _json({
      'connected': UpstoxMarketFeed.instance.isConnected,
      'totalQuotes': MarketStore.instance.getAll().length,
    });
  }

  static Response _dashboard(Request request) {
    final Map<String, dynamic> indices = {};

    _dashboardSymbols.forEach((key, instrumentKey) {
      final tick = MarketStore.instance.get(instrumentKey);
      indices[key] = tick?.toJson();
    });

    return _json({
      'connected': UpstoxMarketFeed.instance.isConnected,
      'marketOpen': MarketStore.instance.getAll().isNotEmpty,
      'indices': indices,
      'lastUpdated': DateTime.now().toIso8601String(),
    });
  }

  static Response _quotes(Request request) {
    return _json(MarketStore.instance.toJson());
  }

  static Response _quote(
    Request request,
    String instrumentKey,
  ) {
    final tick = MarketStore.instance.get(instrumentKey);

    if (tick == null) {
      return Response.notFound(
        jsonEncode({
          'message': 'Quote not found',
        }),
        headers: const {
          'Content-Type': 'application/json',
        },
      );
    }

    return _json(tick.toJson());
  }

  static Response _json(dynamic body) {
    return Response.ok(
      jsonEncode(body),
      headers: const {
        'Content-Type': 'application/json',
      },
    );
  }
}