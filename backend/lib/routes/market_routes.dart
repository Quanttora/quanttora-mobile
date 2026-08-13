import 'dart:convert';

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

  static const Map<String, String> _sectorSymbols = {
    'AUTO': 'NSE_INDEX|Nifty Auto',
    'FMCG': 'NSE_INDEX|Nifty FMCG',
    'IT': 'NSE_INDEX|Nifty IT',
    'METAL': 'NSE_INDEX|Nifty Metal',
    'PHARMA': 'NSE_INDEX|Nifty Pharma',
    'PSU BANK': 'NSE_INDEX|Nifty PSU Bank',
    'REALTY': 'NSE_INDEX|Nifty Realty',
  };

  static Response _status(Request request) {
    return _json({
      'connected':
          UpstoxMarketFeed.instance.isConnected,
      'totalQuotes':
          MarketStore.instance.getAll().length,
    });
  }

  static Response _dashboard(Request request) {
    final Map<String, dynamic> indices = {};

    _dashboardSymbols.forEach(
      (key, instrumentKey) {
        final tick =
            MarketStore.instance.get(
          instrumentKey,
        );

        indices[key] = tick?.toJson();
      },
    );

    final sectors = <Map<String, dynamic>>[];

    _sectorSymbols.forEach(
      (name, instrumentKey) {
        final tick =
            MarketStore.instance.get(
          instrumentKey,
        );

        if (tick == null) {
          return;
        }

        final previousClose = tick.previousClose;

        double percentageChange = 0;

        if (previousClose > 0) {
          percentageChange =
              ((tick.ltp - previousClose) /
                      previousClose) *
                  100;
        }

        sectors.add({
          'name': name,
          'instrumentKey': instrumentKey,
          'ltp': tick.ltp,
          'previousClose': previousClose,
          'percentageChange':
              percentageChange,
          'timestamp':
              tick.timestamp.toIso8601String(),
        });
      },
    );

    sectors.sort(
      (a, b) {
        final aChange =
            a['percentageChange'] as double;

        final bChange =
            b['percentageChange'] as double;

        return bChange.compareTo(aChange);
      },
    );

    Map<String, dynamic>? strongestSector;
    Map<String, dynamic>? weakestSector;

    if (sectors.isNotEmpty) {
      strongestSector = sectors.first;
      weakestSector = sectors.last;
    }

    return _json({
      'connected':
          UpstoxMarketFeed.instance.isConnected,

      'marketOpen':
          MarketStore.instance
              .getAll()
              .isNotEmpty,

      'indices': indices,

      // REAL SECTOR DATA
      'sectors': sectors,

      'sectorStrength': {
        'available': sectors.isNotEmpty,
        'strongest': strongestSector,
        'weakest': weakestSector,
        'totalSectors': sectors.length,
      },

      'lastUpdated':
          DateTime.now().toIso8601String(),
    });
  }

  static Response _quotes(
    Request request,
  ) {
    return _json(
      MarketStore.instance.toJson(),
    );
  }

  static Response _quote(
    Request request,
    String instrumentKey,
  ) {
    final tick =
        MarketStore.instance.get(
      instrumentKey,
    );

    if (tick == null) {
      return Response.notFound(
        jsonEncode({
          'message': 'Quote not found',
        }),
        headers: const {
          'Content-Type':
              'application/json',
        },
      );
    }

    return _json(
      tick.toJson(),
    );
  }

  static Response _json(
    dynamic body,
  ) {
    return Response.ok(
      jsonEncode(body),
      headers: const {
        'Content-Type':
            'application/json',
      },
    );
  }
}