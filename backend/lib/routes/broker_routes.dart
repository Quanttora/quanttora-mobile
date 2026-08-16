import 'dart:convert';

import 'package:backend/integrations/upstox/upstox_broker_service.dart';
import 'package:backend/models/trade_execution_request.dart'
    as trade_execution_models;
import 'package:backend/services/broker_dashboard_service.dart';
import 'package:backend/services/broker_service.dart';
import 'package:backend/services/paper_trade_store.dart';
import 'package:backend/services/trade_execution_guard.dart' as execution_guard;
import 'package:backend/services/upstox_market_feed.dart';
import 'package:backend/services/upstox_option_chain_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class BrokerRoutes {
  final Router router = Router();

  final UpstoxBrokerService _broker = UpstoxBrokerService();

  final BrokerService _brokerService = BrokerService.instance;

  static const execution_guard.TradeExecutionGuard _executionGuard =
      execution_guard.TradeExecutionGuard();

  BrokerRoutes() {
    router.get('/status', _status);

    router.get('/dashboard', _dashboard);

    router.get('/funds', _funds);
    router.get('/quotes', _quotes);
    router.get('/history', _history);

    // REAL OPTION CHAIN
    router.get('/option-chain', _optionChain);

    router.get('/holdings', _holdings);
    router.get('/positions', _positions);

    // ORDER BOOK
    router.get('/orders', _orders);

    // ORDER MANAGEMENT
    router.get('/orders/<orderId>', _orderDetails);

    router.post('/orders', _placeOrder);

    router.put('/orders/<orderId>', _modifyOrder);

    router.delete('/orders/<orderId>', _cancelOrder);

    router.get('/trades', _trades);

    // PAPER TRADING
    router.get('/paper-trades', _paperTrades);

    router.get('/paper-trades/<tradeId>', _paperTradeDetails);

    router.post('/paper-trades/<tradeId>/close', _closePaperTrade);

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
      headers: const {'Content-Type': 'application/json'},
    );
  }

  Response _error(
    int statusCode,
    String message, {
    List<String>? blockingReasons,
  }) {
    return Response(
      statusCode,
      body: jsonEncode({
        'success': false,
        'error': message,
        if (blockingReasons != null) 'blockingReasons': blockingReasons,
      }),
      headers: const {'Content-Type': 'application/json'},
    );
  }

  String _accessToken() {
    return _brokerService.accessToken;
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
        headers: const {'Content-Type': 'application/json'},
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
        headers: const {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _status(Request request) async {
    final session = _brokerService.session;

    return _json({
      'connected': _brokerService.isConnected,
      'marketFeed': UpstoxMarketFeed.instance.isConnected,
      'broker': session?.broker,
      'user': session?.userName,
      'executionGuard': true,
      'paperTrading': true,
      'liveExecution': false,
      'paperTradeCount': PaperTradeStore.instance.count,
      'accessTokenExpired': _brokerService.isAccessTokenExpired,
      'accessTokenExpiresAt': session?.accessTokenExpiresAt?.toIso8601String(),
    });
  }

  Future<Response> _optionChain(Request request) async {
    try {
      final q = request.url.queryParameters;

      final instrumentKey = q['instrumentKey'];

      if (instrumentKey == null || instrumentKey.isEmpty) {
        return _error(400, 'instrumentKey is required');
      }

      final expiry = q['expiry'] ?? 'current_week';

      final result = await UpstoxOptionChainService.instance.getOptionChain(
        instrumentKey: instrumentKey,
        expiryDate: expiry,
      );

      return _json(result);
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: const {'Content-Type': 'application/json'},
      );
    }
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
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: const {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _subscribeMarketFeed(Request request) async {
    final instrumentKey = request.url.queryParameters['instrumentKey'];

    if (instrumentKey == null || instrumentKey.isEmpty) {
      return Response.badRequest(body: 'instrumentKey is required');
    }

    await UpstoxMarketFeed.instance.subscribeFull(instrumentKey);

    return _json({
      'success': true,
      'instrument': instrumentKey,
      'subscriptions': UpstoxMarketFeed.instance.subscriptions,
    });
  }

  Future<Response> _unsubscribeMarketFeed(Request request) async {
    final instrumentKey = request.url.queryParameters['instrumentKey'];

    if (instrumentKey == null || instrumentKey.isEmpty) {
      return Response.badRequest(body: 'instrumentKey is required');
    }

    await UpstoxMarketFeed.instance.unsubscribeFull(instrumentKey);

    return _json({
      'success': true,
      'subscriptions': UpstoxMarketFeed.instance.subscriptions,
    });
  }

  Future<Response> _subscriptions(Request request) async {
    return _json({
      'connected': UpstoxMarketFeed.instance.isConnected,
      'subscriptions': UpstoxMarketFeed.instance.subscriptions,
    });
  }

  Future<Response> _disconnect(Request request) async {
    await UpstoxMarketFeed.instance.disconnect();

    _brokerService.disconnect();

    return _json({'success': true, 'message': 'Broker disconnected'});
  }

  Future<Response> _marketIndices(Request request) async {
    const instruments =
        'NSE_INDEX|Nifty 50,'
        'NSE_INDEX|Nifty Bank,'
        'NSE_INDEX|India VIX';

    return _execute((token) => _broker.getQuotes(token, instruments));
  }

  Future<Response> _funds(Request request) async {
    return _execute((token) => _broker.getFunds(token));
  }

  Future<Response> _holdings(Request request) async {
    return _execute((token) => _broker.getHoldings(token));
  }

  Future<Response> _positions(Request request) async {
    return _execute((token) => _broker.getPositions(token));
  }

  Future<Response> _orders(Request request) async {
    return _execute((token) => _broker.getOrderBook(token));
  }

  Future<Response> _orderDetails(Request request, String orderId) async {
    if (orderId.isEmpty) {
      return _error(400, 'orderId is required');
    }

    return _execute(
      (token) => _broker.getOrderDetails(accessToken: token, orderId: orderId),
    );
  }

  Future<Response> _placeOrder(Request request) async {
    try {
      final rawBody = await request.readAsString();

      if (rawBody.trim().isEmpty) {
        return _error(400, 'Request body is required');
      }

      final decoded = jsonDecode(rawBody);

      if (decoded is! Map) {
        return _error(400, 'Request body must be a JSON object');
      }

      final body = Map<String, dynamic>.from(decoded);

      final executionRequest =
          trade_execution_models.TradeExecutionRequest.fromMap(body);

      if (executionRequest.instrumentToken.isEmpty) {
        return _error(400, 'instrumentToken is required');
      }

      if (executionRequest.quantity <= 0) {
        return _error(400, 'quantity must be greater than 0');
      }

      if (executionRequest.product.isEmpty) {
        return _error(400, 'product is required');
      }

      if (executionRequest.validity.isEmpty) {
        return _error(400, 'validity is required');
      }

      if (executionRequest.price < 0) {
        return _error(400, 'price must be 0 or greater');
      }

      if (executionRequest.orderType.isEmpty) {
        return _error(400, 'orderType is required');
      }

      if (executionRequest.transactionType.isEmpty) {
        return _error(400, 'transactionType is required');
      }

      final brokerConnected = _brokerService.isConnected;

      final marketFeedConnected = UpstoxMarketFeed.instance.isConnected;

      final guardResult = _executionGuard.evaluate(
        brokerConnected: brokerConnected,
        marketFeedConnected: marketFeedConnected,
        constitutionPassed: executionRequest.constitutionPassed,
        strategyPolicyPassed: executionRequest.strategyPolicyPassed,
        aiConfidence: executionRequest.aiConfidence,
        minimumAiScore: executionRequest.minimumAiScore,
        tradesToday: executionRequest.tradesToday,
        maxTradesPerDay: executionRequest.maxTradesPerDay,
        riskReward: executionRequest.riskReward,
        minimumRiskReward: executionRequest.minimumRiskReward,
        liveExecutionEnabled: false,
        paperTrade: executionRequest.paperTrade,
        explicitConfirmation: executionRequest.explicitConfirmation,
      );

      if (!guardResult.allowed) {
        return _error(
          403,
          'Trade execution blocked by Quanttora safety guard.',
          blockingReasons: guardResult.blockingReasons,
        );
      }

      // PAPER TRADE:
      //
      // All Quanttora safety checks must pass.
      // Nothing is sent to the real broker.
      if (executionRequest.paperTrade) {
        final trade = PaperTradeStore.instance.create(
          instrumentToken: executionRequest.instrumentToken,
          quantity: executionRequest.quantity,
          product: executionRequest.product,
          validity: executionRequest.validity,
          entryPrice: executionRequest.price,
          orderType: executionRequest.orderType,
          transactionType: executionRequest.transactionType,
        );

        return _json({
          'success': true,
          'executionAllowed': true,
          'executionMode': 'paper',
          'brokerOrderSubmitted': false,
          'message': 'Paper trade created successfully.',
          'trade': trade.toJson(),
          'order': {
            'instrumentToken': executionRequest.instrumentToken,
            'quantity': executionRequest.quantity,
            'product': executionRequest.product,
            'validity': executionRequest.validity,
            'price': executionRequest.price,
            'orderType': executionRequest.orderType,
            'transactionType': executionRequest.transactionType,
          },
        });
      }

      // LIVE EXECUTION REMAINS LOCKED.
      //
      // Even with explicit confirmation,
      // the final live-execution switch
      // remains OFF until we deliberately
      // enable the production execution path.
      return _error(
        403,
        'Live broker execution is currently disabled.',
        blockingReasons: const ['Quanttora live execution switch is OFF.'],
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: const {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _paperTrades(Request request) async {
    final trades = PaperTradeStore.instance.getAll();

    return _json({
      'success': true,
      'count': trades.length,
      'trades': trades.map((trade) => trade.toJson()).toList(),
    });
  }

  Future<Response> _paperTradeDetails(Request request, String tradeId) async {
    if (tradeId.trim().isEmpty) {
      return _error(400, 'tradeId is required');
    }

    final trade = PaperTradeStore.instance.getById(tradeId);

    if (trade == null) {
      return _error(404, 'Paper trade not found');
    }

    return _json({'success': true, 'trade': trade.toJson()});
  }

  Future<Response> _closePaperTrade(Request request, String tradeId) async {
    if (tradeId.trim().isEmpty) {
      return _error(400, 'tradeId is required');
    }

    final trade = PaperTradeStore.instance.close(tradeId);

    if (trade == null) {
      return _error(404, 'Paper trade not found');
    }

    return _json({
      'success': true,
      'message': 'Paper trade closed.',
      'trade': trade.toJson(),
    });
  }

  Future<Response> _modifyOrder(Request request, String orderId) async {
    try {
      if (orderId.isEmpty) {
        return _error(400, 'orderId is required');
      }

      final rawBody = await request.readAsString();

      if (rawBody.trim().isEmpty) {
        return _error(400, 'Request body is required');
      }

      final decoded = jsonDecode(rawBody);

      if (decoded is! Map) {
        return _error(400, 'Request body must be a JSON object');
      }

      final body = Map<String, dynamic>.from(decoded);

      final quantity = int.tryParse(body['quantity']?.toString() ?? '');

      final price = double.tryParse(body['price']?.toString() ?? '');

      final validity = body['validity']?.toString().trim();

      final orderType = body['orderType']?.toString().trim();

      if (quantity == null || quantity <= 0) {
        return _error(400, 'quantity must be greater than 0');
      }

      if (price == null || price < 0) {
        return _error(400, 'price must be 0 or greater');
      }

      if (validity == null || validity.isEmpty) {
        return _error(400, 'validity is required');
      }

      if (orderType == null || orderType.isEmpty) {
        return _error(400, 'orderType is required');
      }

      final result = await _broker.modifyOrder(
        accessToken: _accessToken(),
        orderId: orderId,
        quantity: quantity,
        validity: validity,
        price: price,
        orderType: orderType,
        triggerPrice:
            double.tryParse(body['triggerPrice']?.toString() ?? '') ?? 0,
        disclosedQuantity:
            int.tryParse(body['disclosedQuantity']?.toString() ?? '') ?? 0,
        marketProtection:
            int.tryParse(body['marketProtection']?.toString() ?? '') ?? -1,
      );

      return _json(result);
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: const {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _cancelOrder(Request request, String orderId) async {
    if (orderId.isEmpty) {
      return _error(400, 'orderId is required');
    }

    return _execute(
      (token) => _broker.cancelOrder(accessToken: token, orderId: orderId),
    );
  }

  Future<Response> _trades(Request request) async {
    return _execute((token) => _broker.getTradeBook(token));
  }

  Future<Response> _quotes(Request request) async {
    final instrumentKey = request.url.queryParameters['instrumentKey'];

    if (instrumentKey == null || instrumentKey.isEmpty) {
      return Response.badRequest(body: 'instrumentKey is required');
    }

    return _execute((token) => _broker.getQuotes(token, instrumentKey));
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
      (token) => _broker.getHistoricalCandles(
        token,
        instrumentKey,
        q['interval'] ?? 'day',
        toDate,
        fromDate,
      ),
    );
  }
}
