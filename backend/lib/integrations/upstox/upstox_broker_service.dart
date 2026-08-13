import 'dart:convert';

import 'package:backend/interfaces/broker_market_interface.dart';
import 'package:http/http.dart' as http;

class UpstoxBrokerService implements BrokerMarketInterface {
  static const String _baseUrl = 'https://api.upstox.com/v2';
  static const String _orderBaseUrl = 'https://api-hft.upstox.com/v3';

  Map<String, String> _headers(String accessToken) {
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, dynamic>> _get(
    String endpoint,
    String accessToken,
  ) async {
    final url = Uri.parse('$_baseUrl$endpoint');

    final response = await http.get(
      url,
      headers: _headers(accessToken),
    );

    print('GET : $url');
    print('STATUS : ${response.statusCode}');
    print('BODY : ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'HTTP ${response.statusCode}\n${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _orderRequest(
    String method,
    String endpoint,
    String accessToken, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$_orderBaseUrl$endpoint');

    final encodedBody = body == null ? null : jsonEncode(body);

    late http.Response response;

    switch (method) {
      case 'POST':
        response = await http.post(
          url,
          headers: _headers(accessToken),
          body: encodedBody,
        );
        break;

      case 'PUT':
        response = await http.put(
          url,
          headers: _headers(accessToken),
          body: encodedBody,
        );
        break;

      case 'DELETE':
        response = await http.delete(
          url,
          headers: _headers(accessToken),
        );
        break;

      default:
        throw ArgumentError(
          'Unsupported HTTP method: $method',
        );
    }

    print('');
    print('============================');
    print('$method : $url');
    print('STATUS : ${response.statusCode}');
    print('BODY   : ${response.body}');
    print('============================');
    print('');

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'HTTP ${response.statusCode}\n${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'Invalid Upstox response.',
      );
    }

    return decoded;
  }

  @override
  Future<Map<String, dynamic>> getFunds(
    String accessToken,
  ) =>
      _get(
        '/user/get-funds-and-margin',
        accessToken,
      );

  @override
  Future<Map<String, dynamic>> getProfile(
    String accessToken,
  ) =>
      _get(
        '/user/profile',
        accessToken,
      );

  @override
  Future<Map<String, dynamic>> getHoldings(
    String accessToken,
  ) =>
      _get(
        '/portfolio/long-term-holdings',
        accessToken,
      );

  @override
  Future<Map<String, dynamic>> getPositions(
    String accessToken,
  ) =>
      _get(
        '/portfolio/short-term-positions',
        accessToken,
      );

  @override
  Future<Map<String, dynamic>> getOrderBook(
    String accessToken,
  ) =>
      _get(
        '/order/retrieve-all',
        accessToken,
      );

  @override
  Future<Map<String, dynamic>> getTradeBook(
    String accessToken,
  ) =>
      _get(
        '/order/trades/get-trades-for-day',
        accessToken,
      );

  @override
  Future<Map<String, dynamic>> getQuotes(
    String accessToken,
    String instrumentKeys,
  ) async {
    final encodedKeys =
        Uri.encodeQueryComponent(instrumentKeys);

    return _get(
      '/market-quote/quotes?instrument_key=$encodedKeys',
      accessToken,
    );
  }

  @override
  Future<Map<String, dynamic>> getHistoricalCandles(
    String accessToken,
    String instrumentKey,
    String interval,
    String toDate,
    String fromDate,
  ) {
    final encodedKey =
        Uri.encodeComponent(instrumentKey);

    return _get(
      '/historical-candle/'
      '$encodedKey/'
      '$interval/'
      '$toDate/'
      '$fromDate',
      accessToken,
    );
  }

  Future<Map<String, dynamic>> placeOrder({
    required String accessToken,
    required String instrumentToken,
    required int quantity,
    required String product,
    required String validity,
    required double price,
    required String orderType,
    required String transactionType,
    int disclosedQuantity = 0,
    double triggerPrice = 0,
    bool isAmo = false,
    bool slice = false,
    int marketProtection = -1,
    String? tag,
  }) {
    final body = <String, dynamic>{
      'quantity': quantity,
      'product': product,
      'validity': validity,
      'price': price,
      'instrument_token': instrumentToken,
      'order_type': orderType,
      'transaction_type': transactionType,
      'disclosed_quantity': disclosedQuantity,
      'trigger_price': triggerPrice,
      'is_amo': isAmo,
      'slice': slice,
      'market_protection': marketProtection,
    };

    if (tag != null && tag.isNotEmpty) {
      body['tag'] = tag;
    }

    return _orderRequest(
      'POST',
      '/order/place',
      accessToken,
      body: body,
    );
  }

  Future<Map<String, dynamic>> modifyOrder({
    required String accessToken,
    required String orderId,
    required int quantity,
    required String validity,
    required double price,
    required String orderType,
    required double triggerPrice,
    int disclosedQuantity = 0,
    int marketProtection = -1,
  }) {
    return _orderRequest(
      'PUT',
      '/order/modify',
      accessToken,
      body: {
        'quantity': quantity,
        'validity': validity,
        'price': price,
        'order_id': orderId,
        'order_type': orderType,
        'disclosed_quantity': disclosedQuantity,
        'trigger_price': triggerPrice,
        'market_protection': marketProtection,
      },
    );
  }

  Future<Map<String, dynamic>> cancelOrder({
    required String accessToken,
    required String orderId,
  }) {
    final encodedOrderId =
        Uri.encodeQueryComponent(orderId);

    return _orderRequest(
      'DELETE',
      '/order/cancel?order_id=$encodedOrderId',
      accessToken,
    );
  }

  Future<Map<String, dynamic>> getOrderDetails({
    required String accessToken,
    required String orderId,
  }) {
    final encodedOrderId =
        Uri.encodeQueryComponent(orderId);

    return _get(
      '/order/details?order_id=$encodedOrderId',
      accessToken,
    );
  }

  Future<Map<String, dynamic>> getOrderHistory({
    required String accessToken,
    String? orderId,
    String? tag,
  }) async {
    final queryParameters = <String, String>{};

    if (orderId != null && orderId.isNotEmpty) {
      queryParameters['order_id'] = orderId;
    }

    if (tag != null && tag.isNotEmpty) {
      queryParameters['tag'] = tag;
    }

    if (queryParameters.isEmpty) {
      throw ArgumentError(
        'Either orderId or tag is required.',
      );
    }

    final query = Uri(
      queryParameters: queryParameters,
    ).query;

    return _get(
      '/order/history?$query',
      accessToken,
    );
  }
}