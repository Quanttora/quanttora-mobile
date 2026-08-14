import 'dart:convert';

import 'package:backend/services/broker_dashboard_service.dart';
import 'package:backend/services/broker_market_service.dart';
import 'package:backend/services/broker/broker_market_feed_service.dart';
import 'package:backend/services/broker/broker_option_chain_service.dart';
import 'package:backend/services/broker_service.dart';
import 'package:backend/services/option_chain/option_chain_analyzer.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class BrokerRoutes {
  final Router router = Router();

  final BrokerService _brokerService = BrokerService.instance;

  final BrokerMarketService _marketService = BrokerMarketService.instance;

  final BrokerMarketFeedService _marketFeedService =
      BrokerMarketFeedService.instance;

  final BrokerOptionChainService _optionChainService =
      BrokerOptionChainService.instance;

  final OptionChainAnalyzer _optionChainAnalyzer = OptionChainAnalyzer.instance;

  BrokerRoutes() {
    router.get('/status', _status);

    router.get('/dashboard', _dashboard);

    router.get('/funds', _funds);
    router.get('/quotes', _quotes);
    router.get('/history', _history);

    router.get('/option-chain', _optionChain);

    router.get('/option-contracts', _optionContracts);

    router.get('/option-analysis', _optionAnalysis);

    router.get('/holdings', _holdings);
    router.get('/positions', _positions);
    router.get('/orders', _orders);
    router.get('/trades', _trades);

    router.get('/market-indices', _marketIndices);

    router.post('/market-feed/connect', _connectMarketFeed);

    router.post('/market-feed/subscribe', _subscribeMarketFeed);

    router.post('/market-feed/unsubscribe', _unsubscribeMarketFeed);

    router.get('/market-feed/subscriptions', _subscriptions);

    router.post('/disconnect', _disconnect);
  }

  Response _json(dynamic data) {
    return Response.ok(
      jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );
  }

  String _accessToken() {
    final session = _brokerService.session;

    if (session == null) {
      throw Exception('No broker connected');
    }

    return session.accessToken;
  }

  Future<Response> _execute(
    Future<dynamic> Function(String token) action,
  ) async {
    try {
      final result = await action(_accessToken());

      return _json(result);
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _dashboard(Request request) async {
    try {
      final result = await BrokerDashboardService.instance.getDashboard();

      return _json(result);
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _status(Request request) async {
    return _json({
      'connected': _brokerService.isConnected,
      'marketFeed':
          _brokerService.isConnected && _marketFeedService.current.isConnected,
      'broker': _brokerService.session?.broker,
      'user': _brokerService.session?.userName,
      'marketServiceSupported':
          _brokerService.isConnected && _marketService.isSupported,
      'marketFeedSupported':
          _brokerService.isConnected && _marketFeedService.isSupported,
      'optionChainSupported':
          _brokerService.isConnected && _optionChainService.isSupported,
    });
  }

  Future<Response> _optionChain(Request request) async {
    try {
      final q = request.url.queryParameters;

      final instrumentKey = q['instrumentKey'];

      if (instrumentKey == null || instrumentKey.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'instrumentKey is required',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final expiry = q['expiry'] ?? 'current_week';

      final result = await _optionChainService.current.getOptionChain(
        instrumentKey: instrumentKey,
        expiryDate: expiry,
      );

      return _json(result);
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _optionContracts(Request request) async {
    try {
      final q = request.url.queryParameters;

      final instrumentKey = q['instrumentKey'];

      if (instrumentKey == null || instrumentKey.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'instrumentKey is required',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final expiry = q['expiry'];

      final result = await _optionChainService.getOptionContracts(
        instrumentKey: instrumentKey,
        expiryDate: expiry,
      );

      return _json(result);
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _optionAnalysis(Request request) async {
    try {
      final q = request.url.queryParameters;

      final instrumentKey = q['instrumentKey'];

      if (instrumentKey == null || instrumentKey.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'instrumentKey is required',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final expiry = q['expiry'] ?? 'current_week';

      final optionChain = await _optionChainService.current.getOptionChain(
        instrumentKey: instrumentKey,
        expiryDate: expiry,
      );

      final analysis = _optionChainAnalyzer.analyze(optionChain: optionChain);

      return _json({
        'status': 'success',
        'instrumentKey': instrumentKey,
        'expiry': expiry,
        'analysis': analysis,
      });
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _connectMarketFeed(Request request) async {
    try {
      await _marketFeedService.current.connect();

      return _json({
        'success': true,
        'connected': _marketFeedService.current.isConnected,
      });
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _subscribeMarketFeed(Request request) async {
    final instrumentKey = request.url.queryParameters['instrumentKey'];

    if (instrumentKey == null || instrumentKey.isEmpty) {
      return Response.badRequest(body: 'instrumentKey is required');
    }

    await _marketFeedService.current.subscribeFull(instrumentKey);

    return _json({
      'success': true,
      'instrument': instrumentKey,
      'subscriptions': _marketFeedService.current.subscriptions,
    });
  }

  Future<Response> _unsubscribeMarketFeed(Request request) async {
    final instrumentKey = request.url.queryParameters['instrumentKey'];

    if (instrumentKey == null || instrumentKey.isEmpty) {
      return Response.badRequest(body: 'instrumentKey is required');
    }

    await _marketFeedService.current.unsubscribeFull(instrumentKey);

    return _json({
      'success': true,
      'subscriptions': _marketFeedService.current.subscriptions,
    });
  }

  Future<Response> _subscriptions(Request request) async {
    if (!_brokerService.isConnected) {
      return _json({'connected': false, 'subscriptions': <String>[]});
    }

    return _json({
      'connected': _marketFeedService.current.isConnected,
      'subscriptions': _marketFeedService.current.subscriptions,
    });
  }

  Future<Response> _disconnect(Request request) async {
    if (_brokerService.isConnected && _marketFeedService.isSupported) {
      await _marketFeedService.current.disconnect();
    }

    _brokerService.disconnect();

    return _json({'success': true, 'message': 'Broker disconnected'});
  }

  Future<Response> _marketIndices(Request request) async {
    const instruments =
        'NSE_INDEX|Nifty 50,'
        'NSE_INDEX|Nifty Bank,'
        'NSE_INDEX|India VIX';

    return _execute(
      (token) => _marketService.current.getQuotes(token, instruments),
    );
  }

  Future<Response> _funds(Request request) async {
    return _execute((token) => _marketService.current.getFunds(token));
  }

  Future<Response> _holdings(Request request) async {
    return _execute((token) => _marketService.current.getHoldings(token));
  }

  Future<Response> _positions(Request request) async {
    return _execute((token) => _marketService.current.getPositions(token));
  }

  Future<Response> _orders(Request request) async {
    return _execute((token) => _marketService.current.getOrderBook(token));
  }

  Future<Response> _trades(Request request) async {
    return _execute((token) => _marketService.current.getTradeBook(token));
  }

  Future<Response> _quotes(Request request) async {
    final instrumentKey = request.url.queryParameters['instrumentKey'];

    if (instrumentKey == null || instrumentKey.isEmpty) {
      return Response.badRequest(body: 'instrumentKey is required');
    }

    return _execute(
      (token) => _marketService.current.getQuotes(token, instrumentKey),
    );
  }

  Future<Response> _history(Request request) async {
    final q = request.url.queryParameters;

    final instrumentKey = q['instrumentKey'];

    final fromDate = q['fromDate'];

    final toDate = q['toDate'];

    if (instrumentKey == null || fromDate == null || toDate == null) {
      return Response.badRequest(
        body: 'instrumentKey, fromDate and toDate are required',
      );
    }

    return _execute(
      (token) => _marketService.current.getHistoricalCandles(
        token,
        instrumentKey,
        q['interval'] ?? 'day',
        toDate,
        fromDate,
      ),
    );
  }
}
