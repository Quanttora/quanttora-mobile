import 'dart:convert';

import 'package:backend/integrations/upstox/upstox_broker_service.dart';
import 'package:backend/middleware/auth_middleware.dart';
import 'package:backend/models/trade_execution_request.dart'
    as trade_execution_models;
import 'package:backend/services/broker_dashboard_service.dart';
import 'package:backend/services/broker_service.dart';
import 'package:backend/services/market_candle_service.dart';
import 'package:backend/services/paper_trade_store.dart';
import 'package:backend/services/trade_execution_guard.dart' as execution_guard;
import 'package:backend/services/upstox_market_feed.dart';
import 'package:backend/services/upstox_option_chain_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class BrokerRoutes {
  BrokerRoutes() {
    router = Router();

    router.get('/status', _status);
    router.get('/dashboard', _dashboard);

    router.get('/funds', _funds);
    router.get('/holdings', _holdings);
    router.get('/positions', _positions);
    router.get('/orders', _orders);
    router.get('/orders/<orderId>', _orderDetails);
    router.get('/trades', _trades);
    router.get('/quotes', _quotes);
    router.get('/market-indices', _marketIndices);
    router.get('/history', _history);
    router.get('/candles', _candles);
    router.get('/option-chain', _optionChain);

    router.post('/orders', _placeOrder);
    router.put('/orders/<orderId>', _modifyOrder);
    router.delete('/orders/<orderId>', _cancelOrder);

    router.get('/paper-trades', _paperTrades);
    router.get('/paper-trades/<tradeId>', _paperTradeDetails);
    router.post('/paper-trades/<tradeId>/close', _closePaperTrade);

    router.post('/disconnect', _disconnect);

    router.post('/market-feed/connect', _connectMarketFeed);
    router.post('/market-feed/subscribe', _subscribeMarketFeed);
    router.post('/market-feed/unsubscribe', _unsubscribeMarketFeed);
    router.get('/market-feed/subscriptions', _subscriptions);

    router.get('/feed/status', _feedStatus);
    router.post('/feed/connect', _connectMarketFeed);
    router.post('/feed/disconnect', _disconnectMarketFeed);
    router.post('/feed/subscribe', _subscribeMarketFeed);
    router.post('/feed/unsubscribe', _unsubscribeMarketFeed);

    router.post('/paper-trade', _paperTrade);
    router.post('/paper-trade/execute', _paperTrade);
    router.get('/paper-trade/status', _paperTradeStatus);
  }

  late final Router router;

  final UpstoxBrokerService _broker = UpstoxBrokerService();

  final BrokerService _brokerService = BrokerService.instance;

  final MarketCandleService _candleService = MarketCandleService.instance;

  static const execution_guard.TradeExecutionGuard _executionGuard =
      execution_guard.TradeExecutionGuard();

  Response _json(dynamic data, {int statusCode = 200}) {
    return Response(
      statusCode,
      body: jsonEncode(data),
      headers: const {'Content-Type': 'application/json'},
    );
  }

  Response _brokerRequired() {
    return _json({
      'success': false,
      'error': {
        'code': 'BROKER_NOT_CONNECTED',
        'message': 'Broker is not connected.',
      },
    }, statusCode: 409);
  }

  Response _brokerError(Object error) {
    return _json({
      'success': false,
      'error': {'code': 'BROKER_ERROR', 'message': error.toString()},
    }, statusCode: 500);
  }

  Response _validationError(String code, String message) {
    return _json({
      'success': false,
      'error': {'code': code, 'message': message},
    }, statusCode: 400);
  }

  int _userId(Request request) {
    final userId = AuthMiddleware.getUserId(request);

    if (userId == null) {
      throw StateError('Authentication is required.');
    }

    return userId;
  }

  String _accessToken(Request request) {
    return _brokerService.accessTokenForUser(_userId(request));
  }

  bool _hasValidSession(Request request) {
    return _brokerService.hasValidSessionForUser(_userId(request));
  }

  Future<Response> _execute(
    Request request,
    Future<dynamic> Function(String token) action,
  ) async {
    try {
      if (!_hasValidSession(request)) {
        return _brokerRequired();
      }

      final result = await action(_accessToken(request));

      return _json(result);
    } catch (error) {
      return _brokerError(error);
    }
  }

  Future<Response> _status(Request request) async {
    try {
      final userId = _userId(request);
      final session = _brokerService.sessionForUser(userId);

      if (session == null) {
        return _json({
          'success': true,
          'connected': false,
          'marketFeed': UpstoxMarketFeed.instance.isConnected,
          'broker': null,
          'user': null,
          'accessTokenExpired': true,
          'accessTokenExpiresAt': null,
          'paperTrading': true,
          'liveExecution': false,
          'paperTradeCount': PaperTradeStore.instance.count,
        });
      }

      return _json({
        'success': true,
        'connected': _brokerService.isConnectedForUser(userId),
        'marketFeed': UpstoxMarketFeed.instance.isConnected,
        'broker': session.broker,
        'user': {
          'id': userId,
          'brokerUserId': session.userId,
          'name': session.userName,
          'email': session.email,
        },
        'executionGuard': true,
        'paperTrading': true,
        'liveExecution': false,
        'paperTradeCount': PaperTradeStore.instance.count,
        'accessTokenExpired': session.isAccessTokenExpired,
        'accessTokenExpiresAt': session.accessTokenExpiresAt?.toIso8601String(),
      });
    } catch (error) {
      return _brokerError(error);
    }
  }

  Future<Response> _dashboard(Request request) async {
    final userId = _userId(request);

    if (!_brokerService.hasValidSessionForUser(userId)) {
      return _brokerRequired();
    }

    try {
      final result = await BrokerDashboardService.instance.getDashboard(
        userId: userId,
      );

      return _json({'success': true, 'data': result});
    } catch (error) {
      return _brokerError(error);
    }
  }

  Future<Response> _funds(Request request) {
    return _execute(request, (token) => _broker.getFunds(token));
  }

  Future<Response> _holdings(Request request) {
    return _execute(request, (token) => _broker.getHoldings(token));
  }

  Future<Response> _positions(Request request) {
    return _execute(request, (token) => _broker.getPositions(token));
  }

  Future<Response> _orders(Request request) {
    return _execute(request, (token) => _broker.getOrderBook(token));
  }

  Future<Response> _trades(Request request) {
    return _execute(request, (token) => _broker.getTradeBook(token));
  }

  Future<Response> _quotes(Request request) async {
    final instrumentKey =
        request.url.queryParameters['instrumentKey'] ??
        request.url.queryParameters['symbol'];

    if (instrumentKey == null || instrumentKey.trim().isEmpty) {
      return _validationError(
        'INSTRUMENT_REQUIRED',
        'instrumentKey is required.',
      );
    }

    return _execute(
      request,
      (token) => _broker.getQuotes(token, instrumentKey.trim()),
    );
  }

  Future<Response> _marketIndices(Request request) {
    const instruments =
        'NSE_INDEX|Nifty 50,'
        'NSE_INDEX|Nifty Bank,'
        'BSE_INDEX|SENSEX,'
        'NSE_INDEX|India VIX';

    return _execute(request, (token) => _broker.getQuotes(token, instruments));
  }

  Future<Response> _history(Request request) async {
    final q = request.url.queryParameters;

    final instrumentKey = q['instrumentKey'];
    final fromDate = q['fromDate'] ?? q['from'];
    final toDate = q['toDate'] ?? q['to'];
    final interval = q['interval'] ?? 'day';

    if (instrumentKey == null ||
        instrumentKey.trim().isEmpty ||
        fromDate == null ||
        fromDate.trim().isEmpty ||
        toDate == null ||
        toDate.trim().isEmpty) {
      return _validationError(
        'HISTORY_PARAMETERS_REQUIRED',
        'instrumentKey, fromDate and toDate are required.',
      );
    }

    return _execute(
      request,
      (token) => _broker.getHistoricalCandles(
        token,
        instrumentKey.trim(),
        interval,
        toDate.trim(),
        fromDate.trim(),
      ),
    );
  }

  Future<Response> _candles(Request request) async {
    final q = request.url.queryParameters;

    final instrumentKey = q['instrumentKey'];
    final interval = q['interval'] ?? '1minute';
    final fromDate = q['fromDate'] ?? q['from'];
    final toDate = q['toDate'] ?? q['to'];

    if (instrumentKey == null ||
        instrumentKey.trim().isEmpty ||
        fromDate == null ||
        fromDate.trim().isEmpty ||
        toDate == null ||
        toDate.trim().isEmpty) {
      return _validationError(
        'CANDLE_PARAMETERS_REQUIRED',
        'instrumentKey, fromDate and toDate are required.',
      );
    }

    try {
      if (!_hasValidSession(request)) {
        return _brokerRequired();
      }

      final candles = await _candleService.getHistoricalCandles(
        instrumentKey: instrumentKey.trim(),
        interval: interval,
        fromDate: fromDate.trim(),
        toDate: toDate.trim(),
      );

      final vwap = await _candleService.calculateHistoricalVwap(
        instrumentKey: instrumentKey.trim(),
        interval: interval,
        fromDate: fromDate.trim(),
        toDate: toDate.trim(),
      );

      return _json({
        'success': true,
        'instrumentKey': instrumentKey.trim(),
        'interval': interval,
        'fromDate': fromDate.trim(),
        'toDate': toDate.trim(),
        'candleCount': candles.length,
        'vwap': vwap,
        'candles': candles.map((candle) => candle.toJson()).toList(),
      });
    } catch (error) {
      return _brokerError(error);
    }
  }

  Future<Response> _optionChain(Request request) async {
    try {
      if (!_hasValidSession(request)) {
        return _brokerRequired();
      }

      final instrumentKey = request.url.queryParameters['instrumentKey'];

      if (instrumentKey == null || instrumentKey.trim().isEmpty) {
        return _validationError(
          'INSTRUMENT_REQUIRED',
          'instrumentKey is required.',
        );
      }

      final expiry =
          request.url.queryParameters['expiry'] ??
          request.url.queryParameters['expiryDate'] ??
          'current_week';

      final result = await UpstoxOptionChainService.instance.getOptionChain(
        instrumentKey: instrumentKey.trim(),
        expiryDate: expiry,
      );

      return _json(result);
    } catch (error) {
      return _brokerError(error);
    }
  }

  Future<Response> _orderDetails(Request request, String orderId) {
    if (orderId.trim().isEmpty) {
      return Future.value(
        _validationError('ORDER_ID_REQUIRED', 'orderId is required.'),
      );
    }

    return _execute(
      request,
      (token) =>
          _broker.getOrderDetails(accessToken: token, orderId: orderId.trim()),
    );
  }

  Future<Response> _placeOrder(Request request) async {
    try {
      final userId = _userId(request);

      final rawBody = await request.readAsString();

      if (rawBody.trim().isEmpty) {
        return _validationError(
          'REQUEST_BODY_REQUIRED',
          'Request body is required.',
        );
      }

      final decoded = jsonDecode(rawBody);

      if (decoded is! Map) {
        return _validationError(
          'INVALID_REQUEST',
          'Request body must be a JSON object.',
        );
      }

      final body = Map<String, dynamic>.from(decoded);

      final executionRequest =
          trade_execution_models.TradeExecutionRequest.fromMap(body);

      if (executionRequest.instrumentToken.trim().isEmpty) {
        return _validationError(
          'INSTRUMENT_REQUIRED',
          'instrumentToken is required.',
        );
      }

      if (executionRequest.quantity <= 0) {
        return _validationError(
          'INVALID_QUANTITY',
          'quantity must be greater than 0.',
        );
      }

      if (executionRequest.product.trim().isEmpty) {
        return _validationError('PRODUCT_REQUIRED', 'product is required.');
      }

      if (executionRequest.validity.trim().isEmpty) {
        return _validationError('VALIDITY_REQUIRED', 'validity is required.');
      }

      if (executionRequest.orderType.trim().isEmpty) {
        return _validationError(
          'ORDER_TYPE_REQUIRED',
          'orderType is required.',
        );
      }

      if (executionRequest.transactionType.trim().isEmpty) {
        return _validationError(
          'TRANSACTION_TYPE_REQUIRED',
          'transactionType is required.',
        );
      }

      if (executionRequest.price < 0) {
        return _validationError('INVALID_PRICE', 'price must be 0 or greater.');
      }

      final brokerConnected = _brokerService.hasValidSessionForUser(userId);

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
        return _json({
          'success': false,
          'executionAllowed': false,
          'error': {
            'code': 'TRADE_EXECUTION_BLOCKED',
            'message': 'Trade execution blocked by Quanttora safety guard.',
          },
          'blockingReasons': guardResult.blockingReasons,
        }, statusCode: 403);
      }

      if (executionRequest.paperTrade) {
        final paperTrade = PaperTradeStore.instance.create(
          instrumentToken: executionRequest.instrumentToken.trim(),
          quantity: executionRequest.quantity,
          product: executionRequest.product.trim(),
          validity: executionRequest.validity.trim(),
          entryPrice: executionRequest.price,
          orderType: executionRequest.orderType.trim(),
          transactionType: executionRequest.transactionType.trim(),
        );

        return _json({
          'success': true,
          'paperTrade': true,
          'data': paperTrade.toJson(),
        }, statusCode: 201);
      }

      if (!_brokerService.hasValidSessionForUser(userId)) {
        return _brokerRequired();
      }

      final result = await _broker.placeOrder(
        accessToken: _accessToken(request),
        instrumentToken: executionRequest.instrumentToken.trim(),
        quantity: executionRequest.quantity,
        product: executionRequest.product.trim(),
        validity: executionRequest.validity.trim(),
        price: executionRequest.price,
        orderType: executionRequest.orderType.trim(),
        transactionType: executionRequest.transactionType.trim(),
        disclosedQuantity:
            int.tryParse(body['disclosedQuantity']?.toString() ?? '') ?? 0,
        triggerPrice:
            double.tryParse(body['triggerPrice']?.toString() ?? '') ?? 0,
        isAmo: body['isAmo'] == true,
        slice: body['slice'] == true,
        marketProtection:
            int.tryParse(body['marketProtection']?.toString() ?? '') ?? -1,
        tag: body['tag']?.toString(),
      );

      return _json({'success': true, 'paperTrade': false, 'data': result});
    } catch (error) {
      return _brokerError(error);
    }
  }

  Future<Response> _modifyOrder(Request request, String orderId) async {
    try {
      if (orderId.trim().isEmpty) {
        return _validationError('ORDER_ID_REQUIRED', 'orderId is required.');
      }

      if (!_hasValidSession(request)) {
        return _brokerRequired();
      }

      final rawBody = await request.readAsString();

      if (rawBody.trim().isEmpty) {
        return _validationError(
          'REQUEST_BODY_REQUIRED',
          'Request body is required.',
        );
      }

      final decoded = jsonDecode(rawBody);

      if (decoded is! Map) {
        return _validationError(
          'INVALID_REQUEST',
          'Request body must be a JSON object.',
        );
      }

      final body = Map<String, dynamic>.from(decoded);

      final quantity = int.tryParse(body['quantity']?.toString() ?? '');

      final price = double.tryParse(body['price']?.toString() ?? '');

      final validity = body['validity']?.toString().trim();

      final orderType = body['orderType']?.toString().trim();

      if (quantity == null || quantity <= 0) {
        return _validationError(
          'INVALID_QUANTITY',
          'quantity must be greater than 0.',
        );
      }

      if (price == null || price < 0) {
        return _validationError('INVALID_PRICE', 'price must be 0 or greater.');
      }

      if (validity == null || validity.isEmpty) {
        return _validationError('VALIDITY_REQUIRED', 'validity is required.');
      }

      if (orderType == null || orderType.isEmpty) {
        return _validationError(
          'ORDER_TYPE_REQUIRED',
          'orderType is required.',
        );
      }

      final result = await _broker.modifyOrder(
        accessToken: _accessToken(request),
        orderId: orderId.trim(),
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

      return _json({'success': true, 'data': result});
    } catch (error) {
      return _brokerError(error);
    }
  }

  Future<Response> _cancelOrder(Request request, String orderId) {
    if (orderId.trim().isEmpty) {
      return Future.value(
        _validationError('ORDER_ID_REQUIRED', 'orderId is required.'),
      );
    }

    return _execute(
      request,
      (token) =>
          _broker.cancelOrder(accessToken: token, orderId: orderId.trim()),
    );
  }

  Response _paperTrades(Request request) {
    _userId(request);

    final trades = PaperTradeStore.instance.getAll();

    return _json({
      'success': true,
      'data': trades.map((trade) => trade.toJson()).toList(),
    });
  }

  Response _paperTradeDetails(Request request, String tradeId) {
    _userId(request);

    final trade = PaperTradeStore.instance.getById(tradeId.trim());

    if (trade == null) {
      return _json({
        'success': false,
        'error': {
          'code': 'PAPER_TRADE_NOT_FOUND',
          'message': 'Paper trade not found.',
        },
      }, statusCode: 404);
    }

    return _json({'success': true, 'data': trade.toJson()});
  }

  Response _closePaperTrade(Request request, String tradeId) {
    _userId(request);

    final trade = PaperTradeStore.instance.close(tradeId.trim());

    if (trade == null) {
      return _json({
        'success': false,
        'error': {
          'code': 'PAPER_TRADE_NOT_FOUND',
          'message': 'Paper trade not found.',
        },
      }, statusCode: 404);
    }

    return _json({'success': true, 'data': trade.toJson()});
  }

  Future<Response> _paperTrade(Request request) async {
    _userId(request);

    return _placeOrder(request);
  }

  Response _paperTradeStatus(Request request) {
    final userId = _userId(request);

    return _json({
      'success': true,
      'data': {
        'userId': userId,
        'supported': true,
        'paperTradeCount': PaperTradeStore.instance.count,
      },
    });
  }

  Response _feedStatus(Request request) {
    final userId = _userId(request);

    final session = _brokerService.sessionForUser(userId);

    return _json({
      'success': true,
      'connected': UpstoxMarketFeed.instance.isConnected,
      'brokerConnected':
          session != null && _brokerService.isConnectedForUser(userId),
      'userId': userId,
      'subscriptions': UpstoxMarketFeed.instance.subscriptions,
    });
  }

  Future<Response> _connectMarketFeed(Request request) async {
    final userId = _userId(request);

    if (!_brokerService.hasValidSessionForUser(userId)) {
      return _brokerRequired();
    }

    try {
      await UpstoxMarketFeed.instance.connect();

      return _json({
        'success': true,
        'connected': UpstoxMarketFeed.instance.isConnected,
      });
    } catch (error) {
      return _brokerError(error);
    }
  }

  Future<Response> _disconnectMarketFeed(Request request) async {
    _userId(request);

    try {
      await UpstoxMarketFeed.instance.disconnect();

      return _json({'success': true, 'connected': false});
    } catch (error) {
      return _brokerError(error);
    }
  }

  Future<Response> _subscribeMarketFeed(Request request) async {
    _userId(request);

    final instrumentKey = request.url.queryParameters['instrumentKey'];

    if (instrumentKey == null || instrumentKey.trim().isEmpty) {
      return _validationError(
        'INSTRUMENT_REQUIRED',
        'instrumentKey is required.',
      );
    }

    try {
      await UpstoxMarketFeed.instance.subscribeFull(instrumentKey.trim());

      return _json({
        'success': true,
        'instrument': instrumentKey.trim(),
        'subscriptions': UpstoxMarketFeed.instance.subscriptions,
      });
    } catch (error) {
      return _brokerError(error);
    }
  }

  Future<Response> _unsubscribeMarketFeed(Request request) async {
    _userId(request);

    final instrumentKey = request.url.queryParameters['instrumentKey'];

    if (instrumentKey == null || instrumentKey.trim().isEmpty) {
      return _validationError(
        'INSTRUMENT_REQUIRED',
        'instrumentKey is required.',
      );
    }

    try {
      await UpstoxMarketFeed.instance.unsubscribeFull(instrumentKey.trim());

      return _json({
        'success': true,
        'subscriptions': UpstoxMarketFeed.instance.subscriptions,
      });
    } catch (error) {
      return _brokerError(error);
    }
  }

  Response _subscriptions(Request request) {
    _userId(request);

    return _json({
      'success': true,
      'connected': UpstoxMarketFeed.instance.isConnected,
      'subscriptions': UpstoxMarketFeed.instance.subscriptions,
    });
  }

  Future<Response> _disconnect(Request request) async {
    final userId = _userId(request);

    try {
      await UpstoxMarketFeed.instance.disconnect();

      _brokerService.disconnectForUser(userId);

      return _json({
        'success': true,
        'connected': false,
        'message': 'Broker disconnected.',
      });
    } catch (error) {
      return _brokerError(error);
    }
  }
}
