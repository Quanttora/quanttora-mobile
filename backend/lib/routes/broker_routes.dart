import 'dart:convert';

import 'package:backend/integrations/upstox/upstox_broker_service.dart';
import 'package:backend/services/broker_dashboard_service.dart';
import 'package:backend/services/broker_service.dart';
import 'package:backend/services/upstox_market_feed.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class BrokerRoutes {
  final Router router = Router();

  final UpstoxBrokerService _broker =
      UpstoxBrokerService();

  final BrokerService _brokerService =
      BrokerService.instance;

  BrokerRoutes() {
    router.get('/status', _status);

    router.get('/dashboard', _dashboard);

    router.get('/funds', _funds);
    router.get('/quotes', _quotes);
    router.get('/history', _history);

    router.get('/holdings', _holdings);
    router.get('/positions', _positions);
    router.get('/orders', _orders);
    router.get('/trades', _trades);

    router.get(
      '/market-indices',
      _marketIndices,
    );

    router.post(
      '/market-feed/connect',
      _connectMarketFeed,
    );

    router.post(
      '/market-feed/subscribe',
      _subscribeMarketFeed,
    );

    router.post(
      '/market-feed/unsubscribe',
      _unsubscribeMarketFeed,
    );

    router.get(
      '/market-feed/subscriptions',
      _subscriptions,
    );

    router.post(
      '/disconnect',
      _disconnect,
    );
  }

  Response _json(dynamic data) =>
      Response.ok(
        jsonEncode(data),
        headers: {
          'Content-Type':
              'application/json',
        },
      );

  String _accessToken() {
    final session =
        _brokerService.session;

    if (session == null) {
      throw Exception(
        'No broker connected',
      );
    }

    return session.accessToken;
  }

  Future<Response> _execute(
    Future<dynamic> Function(
      String token,
    )
        action,
  ) async {
    try {
      final result = await action(
        _accessToken(),
      );

      return _json(result);
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {
          'Content-Type':
              'application/json',
        },
      );
    }
  }
    Future<Response> _dashboard(Request request) async {
    try {
      final result =
          await BrokerDashboardService.instance.getDashboard();

      return _json(result);
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    }
  }

  Future<Response> _status(Request request) async {
    return _json({
      'connected': _brokerService.isConnected,
      'marketFeed': UpstoxMarketFeed.instance.isConnected,
      'broker': _brokerService.session?.broker,
      'user': _brokerService.session?.userName,
    });
  }

  Future<Response> _connectMarketFeed(Request request) async {
    try {
      await UpstoxMarketFeed.instance.connect();

      return _json({
        'success': true,
        'connected': UpstoxMarketFeed.instance.isConnected,
      });
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': e.toString(),
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    }
  }

  Future<Response> _subscribeMarketFeed(Request request) async {
    final instrumentKey =
        request.url.queryParameters['instrumentKey'];

    if (instrumentKey == null || instrumentKey.isEmpty) {
      return Response.badRequest(
        body: 'instrumentKey is required',
      );
    }

    await UpstoxMarketFeed.instance.subscribeFull(
      instrumentKey,
    );

    return _json({
      'success': true,
      'instrument': instrumentKey,
      'subscriptions':
          UpstoxMarketFeed.instance.subscriptions,
    });
  }

  Future<Response> _unsubscribeMarketFeed(Request request) async {
    final instrumentKey =
        request.url.queryParameters['instrumentKey'];

    if (instrumentKey == null || instrumentKey.isEmpty) {
      return Response.badRequest(
        body: 'instrumentKey is required',
      );
    }

    await UpstoxMarketFeed.instance.unsubscribeFull(
      instrumentKey,
    );

    return _json({
      'success': true,
      'subscriptions':
          UpstoxMarketFeed.instance.subscriptions,
    });
  }

  Future<Response> _subscriptions(Request request) async {
    return _json({
      'connected':
          UpstoxMarketFeed.instance.isConnected,
      'subscriptions':
          UpstoxMarketFeed.instance.subscriptions,
    });
  }

  Future<Response> _disconnect(Request request) async {
    await UpstoxMarketFeed.instance.disconnect();

    _brokerService.disconnect();

    return _json({
      'success': true,
      'message': 'Broker disconnected',
    });
  }

  Future<Response> _marketIndices(Request request) async {
    const instruments =
        'NSE_INDEX|Nifty 50,'
        'NSE_INDEX|Nifty Bank,'
        'NSE_INDEX|India VIX';

    return _execute(
      (token) => _broker.getQuotes(
        token,
        instruments,
      ),
    );
  }
    Future<Response> _funds(Request request) async {
    return _execute(
      (token) => _broker.getFunds(token),
    );
  }

  Future<Response> _holdings(Request request) async {
    return _execute(
      (token) => _broker.getHoldings(token),
    );
  }

  Future<Response> _positions(Request request) async {
    return _execute(
      (token) => _broker.getPositions(token),
    );
  }

  Future<Response> _orders(Request request) async {
    return _execute(
      (token) => _broker.getOrderBook(token),
    );
  }

  Future<Response> _trades(Request request) async {
    return _execute(
      (token) => _broker.getTradeBook(token),
    );
  }

  Future<Response> _quotes(Request request) async {
    final instrumentKey =
        request.url.queryParameters['instrumentKey'];

    if (instrumentKey == null ||
        instrumentKey.isEmpty) {
      return Response.badRequest(
        body: 'instrumentKey is required',
      );
    }

    return _execute(
      (token) => _broker.getQuotes(
        token,
        instrumentKey,
      ),
    );
  }

  Future<Response> _history(Request request) async {
    final q = request.url.queryParameters;

    final instrumentKey =
        q['instrumentKey'];
    final fromDate = q['fromDate'];
    final toDate = q['toDate'];

    if (instrumentKey == null ||
        fromDate == null ||
        toDate == null) {
      return Response.badRequest(
        body:
            'instrumentKey, fromDate and toDate are required',
      );
    }

    return _execute(
      (token) =>
          _broker.getHistoricalCandles(
        token,
        instrumentKey,
        q['interval'] ?? 'day',
        toDate,
        fromDate,
      ),
    );
  }
}