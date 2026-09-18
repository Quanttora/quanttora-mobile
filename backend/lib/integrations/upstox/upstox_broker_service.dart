import 'dart:convert';

import 'package:backend/interfaces/broker_market_interface.dart';
import 'package:http/http.dart' as http;

class UpstoxBrokerService implements BrokerMarketInterface {
  static const String _apiBaseUrl = 'https://api.upstox.com/v2';

  static const String _v3ApiBaseUrl = 'https://api.upstox.com/v3';

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
    final url = Uri.parse('$_apiBaseUrl$endpoint');

    final response = await http
        .get(url, headers: _headers(accessToken))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Upstox GET failed '
        '(${response.statusCode}): '
        '${response.body}',
      );
    }

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _getV3(
    String endpoint,
    String accessToken,
  ) async {
    final url = Uri.parse('$_v3ApiBaseUrl$endpoint');

    final response = await http
        .get(url, headers: _headers(accessToken))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Upstox V3 GET failed '
        '(${response.statusCode}): '
        '${response.body}',
      );
    }

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _orderRequest(
    String method,
    String endpoint,
    String accessToken, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$_orderBaseUrl$endpoint');

    final headers = _headers(accessToken);

    final encodedBody = body == null ? null : jsonEncode(body);

    late http.Response response;

    switch (method) {
      case 'POST':
        response = await http
            .post(url, headers: headers, body: encodedBody)
            .timeout(const Duration(seconds: 15));
        break;

      case 'PUT':
        response = await http
            .put(url, headers: headers, body: encodedBody)
            .timeout(const Duration(seconds: 15));
        break;

      case 'DELETE':
        response = await http
            .delete(url, headers: headers)
            .timeout(const Duration(seconds: 15));
        break;

      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Upstox order request failed '
        '($method ${response.statusCode}): '
        '${response.body}',
      );
    }

    return _decodeResponse(response);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.trim().isEmpty) {
      throw Exception('Upstox returned an empty response.');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception('Invalid Upstox response format.');
    }

    return Map<String, dynamic>.from(decoded);
  }

  @override
  Future<Map<String, dynamic>> getFunds(String accessToken) {
    return _get('/user/get-funds-and-margin', accessToken);
  }

  @override
  Future<Map<String, dynamic>> getProfile(String accessToken) {
    return _get('/user/profile', accessToken);
  }

  @override
  Future<Map<String, dynamic>> getHoldings(String accessToken) {
    return _get('/portfolio/long-term-holdings', accessToken);
  }

  @override
  Future<Map<String, dynamic>> getPositions(String accessToken) {
    return _get('/portfolio/short-term-positions', accessToken);
  }

  @override
  Future<Map<String, dynamic>> getOrderBook(String accessToken) {
    return _get('/order/retrieve-all', accessToken);
  }

  @override
  Future<Map<String, dynamic>> getTradeBook(String accessToken) {
    return _get('/order/trades/get-trades-for-day', accessToken);
  }

  @override
  Future<Map<String, dynamic>> getQuotes(
    String accessToken,
    String instrumentKeys,
  ) async {
    final encodedKeys = Uri.encodeQueryComponent(instrumentKeys);

    return _get(
      '/market-quote/quotes'
      '?instrument_key=$encodedKeys',
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
  ) async {
    final timeframe = _parseTimeframe(interval);
    final startDate = _parseDateOnly(fromDate, 'fromDate');
    final endDate = _parseDateOnly(toDate, 'toDate');

    if (endDate.isBefore(startDate)) {
      throw ArgumentError('toDate must be greater than or equal to fromDate.');
    }

    final chunkDays = _historicalChunkDays(timeframe);
    final candles = <List<dynamic>>[];

    var chunkStart = startDate;

    while (!chunkStart.isAfter(endDate)) {
      final candidateEnd = chunkStart.add(
        Duration(days: chunkDays - 1),
      );
      final chunkEnd = candidateEnd.isBefore(endDate)
          ? candidateEnd
          : endDate;

      final response = await _getHistoricalCandleChunk(
        accessToken: accessToken,
        instrumentKey: instrumentKey,
        timeframe: timeframe,
        fromDate: _formatDateOnly(chunkStart),
        toDate: _formatDateOnly(chunkEnd),
      );

      candles.addAll(_extractCandles(response));

      if (chunkEnd.isAtSameMomentAs(endDate)) {
        break;
      }

      chunkStart = chunkEnd.add(const Duration(days: 1));
    }

    final uniqueCandles = <String, List<dynamic>>{};

    for (final candle in candles) {
      if (candle.isEmpty) {
        continue;
      }

      final timestamp = candle.first.toString();
      if (timestamp.isNotEmpty) {
        uniqueCandles[timestamp] = candle;
      }
    }

    final mergedCandles = uniqueCandles.values.toList()
      ..sort((a, b) => _candleTimestamp(a).compareTo(_candleTimestamp(b)));

    return <String, dynamic>{
      'status': 'success',
      'data': <String, dynamic>{
        'candles': mergedCandles,
      },
    };
  }

  Future<Map<String, dynamic>> _getHistoricalCandleChunk({
    required String accessToken,
    required String instrumentKey,
    required _Timeframe timeframe,
    required String toDate,
    required String fromDate,
  }) {
    final encodedKey = Uri.encodeComponent(instrumentKey);
    final encodedUnit = Uri.encodeComponent(timeframe.unit);
    final encodedInterval = Uri.encodeComponent(
      timeframe.interval.toString(),
    );
    final encodedToDate = Uri.encodeComponent(toDate);
    final encodedFromDate = Uri.encodeComponent(fromDate);

    return _getV3(
      '/historical-candle/'
      '$encodedKey/'
      '$encodedUnit/'
      '$encodedInterval/'
      '$encodedToDate/'
      '$encodedFromDate',
      accessToken,
    );
  }

  int _historicalChunkDays(_Timeframe timeframe) {
    if (timeframe.unit == 'minutes') {
      return timeframe.interval <= 15 ? 28 : 85;
    }

    if (timeframe.unit == 'hours') {
      return 85;
    }

    if (timeframe.unit == 'days') {
      return 3650;
    }

    if (timeframe.unit == 'weeks') {
      return 3650;
    }

    if (timeframe.unit == 'months') {
      return 3650;
    }

    throw ArgumentError(
      'Unsupported historical timeframe unit: ${timeframe.unit}',
    );
  }

  List<List<dynamic>> _extractCandles(Map<String, dynamic> response) {
    final data = response['data'];

    if (data is! Map) {
      return <List<dynamic>>[];
    }

    final rawCandles = data['candles'];

    if (rawCandles is! List) {
      return <List<dynamic>>[];
    }

    return rawCandles
        .whereType<List>()
        .map((candle) => List<dynamic>.from(candle))
        .toList();
  }

  int _candleTimestamp(List<dynamic> candle) {
    if (candle.isEmpty) {
      return 0;
    }

    final rawTimestamp = candle.first;

    if (rawTimestamp is num) {
      return rawTimestamp.toInt();
    }

    if (rawTimestamp is String) {
      return DateTime.parse(rawTimestamp).millisecondsSinceEpoch;
    }

    return 0;
  }

  DateTime _parseDateOnly(String value, String fieldName) {
    try {
      final parsed = DateTime.parse(value);
      return DateTime(parsed.year, parsed.month, parsed.day);
    } catch (_) {
      throw ArgumentError(
        '$fieldName must use YYYY-MM-DD format: $value',
      );
    }
  }

  String _formatDateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');

    return '${value.year.toString().padLeft(4, '0')}-$month-$day';
  }

  /// Returns candles for the current trading day.
  ///
  /// Upstox V3 provides current-day candles through the dedicated
  /// intraday endpoint instead of the date-range historical endpoint.
  @override
  Future<Map<String, dynamic>> getIntradayCandles(
    String accessToken,
    String instrumentKey,
    String interval,
  ) {
    final timeframe = _parseIntradayTimeframe(interval);

    final encodedKey = Uri.encodeComponent(instrumentKey);
    final encodedUnit = Uri.encodeComponent(timeframe.unit);
    final encodedInterval = Uri.encodeComponent(
      timeframe.interval.toString(),
    );

    return _getV3(
      '/historical-candle/intraday/'
      '$encodedKey/'
      '$encodedUnit/'
      '$encodedInterval',
      accessToken,
    );
  }

  _Timeframe _parseIntradayTimeframe(String value) {
    final timeframe = _parseTimeframe(value);

    if (timeframe.unit != 'minutes' &&
        timeframe.unit != 'hours' &&
        timeframe.unit != 'days') {
      throw ArgumentError(
        'Intraday timeframe must use minutes, hours or days.',
      );
    }

    if (timeframe.unit == 'days' && timeframe.interval != 1) {
      throw ArgumentError(
        'Intraday day timeframe must be 1 day.',
      );
    }

    return timeframe;
  }

  _Timeframe _parseTimeframe(String value) {
    final normalized = value.trim().toLowerCase();

    if (normalized.isEmpty) {
      throw ArgumentError('Historical candle timeframe is required.');
    }

    if (normalized == 'day' ||
        normalized == '1day' ||
        normalized == '1d') {
      return const _Timeframe(unit: 'days', interval: 1);
    }

    if (normalized == 'week' ||
        normalized == '1week' ||
        normalized == '1w') {
      return const _Timeframe(unit: 'weeks', interval: 1);
    }

    if (normalized == 'month' ||
        normalized == '1month' ||
        normalized == '1mo') {
      return const _Timeframe(unit: 'months', interval: 1);
    }

    final minuteMatch = RegExp(
      r'^(\d+)\s*(m|min|mins|minute|minutes)$',
    ).firstMatch(normalized);

    if (minuteMatch != null) {
      final interval = int.parse(minuteMatch.group(1)!);

      if (interval < 1 || interval > 300) {
        throw ArgumentError(
          'Minute timeframe must be between '
          '1 and 300.',
        );
      }

      return _Timeframe(unit: 'minutes', interval: interval);
    }

    final hourMatch = RegExp(
      r'^(\d+)\s*(h|hr|hrs|hour|hours)$',
    ).firstMatch(normalized);

    if (hourMatch != null) {
      final interval = int.parse(hourMatch.group(1)!);

      if (interval < 1 || interval > 5) {
        throw ArgumentError(
          'Hour timeframe must be between '
          '1 and 5.',
        );
      }

      return _Timeframe(unit: 'hours', interval: interval);
    }

    final numericMatch = RegExp(r'^(\d+)$').firstMatch(normalized);

    if (numericMatch != null) {
      final interval = int.parse(numericMatch.group(1)!);

      if (interval < 1 || interval > 300) {
        throw ArgumentError(
          'Numeric timeframe must be between '
          '1 and 300 minutes.',
        );
      }

      return _Timeframe(unit: 'minutes', interval: interval);
    }

    throw ArgumentError('Unsupported timeframe: $value');
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
    if (quantity <= 0) {
      throw ArgumentError('Order quantity must be greater than zero.');
    }

    if (instrumentToken.trim().isEmpty) {
      throw ArgumentError('Instrument token is required.');
    }

    if (product != 'I' && product != 'D' && product != 'MTF') {
      throw ArgumentError('Invalid product: $product');
    }

    if (validity != 'DAY' && validity != 'IOC') {
      throw ArgumentError('Invalid validity: $validity');
    }

    if (orderType != 'MARKET' &&
        orderType != 'LIMIT' &&
        orderType != 'SL' &&
        orderType != 'SL-M') {
      throw ArgumentError('Invalid order type: $orderType');
    }

    if (transactionType != 'BUY' && transactionType != 'SELL') {
      throw ArgumentError(
        'Invalid transaction type: '
        '$transactionType',
      );
    }

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

    if (tag != null && tag.trim().isNotEmpty) {
      body['tag'] = tag.trim();
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
    if (orderId.trim().isEmpty) {
      throw ArgumentError('Order ID is required.');
    }

    if (quantity <= 0) {
      throw ArgumentError('Order quantity must be greater than zero.');
    }

    final body = <String, dynamic>{
      'quantity': quantity,
      'validity': validity,
      'price': price,
      'order_id': orderId,
      'order_type': orderType,
      'disclosed_quantity': disclosedQuantity,
      'trigger_price': triggerPrice,
      'market_protection': marketProtection,
    };

    return _orderRequest(
      'PUT',
      '/order/modify',
      accessToken,
      body: body,
    );
  }

  Future<Map<String, dynamic>> cancelOrder({
    required String accessToken,
    required String orderId,
  }) {
    if (orderId.trim().isEmpty) {
      throw ArgumentError('Order ID is required.');
    }

    final encodedOrderId = Uri.encodeQueryComponent(orderId);

    return _orderRequest(
      'DELETE',
      '/order/cancel'
          '?order_id=$encodedOrderId',
      accessToken,
    );
  }

  Future<Map<String, dynamic>> getOrderDetails({
    required String accessToken,
    required String orderId,
  }) {
    if (orderId.trim().isEmpty) {
      throw ArgumentError('Order ID is required.');
    }

    final encodedOrderId = Uri.encodeQueryComponent(orderId);

    return _get(
      '/order/details'
      '?order_id=$encodedOrderId',
      accessToken,
    );
  }

  Future<Map<String, dynamic>> getOrderHistory({
    required String accessToken,
    String? orderId,
    String? tag,
  }) async {
    final queryParameters = <String, String>{};

    if (orderId != null && orderId.trim().isNotEmpty) {
      queryParameters['order_id'] = orderId.trim();
    }

    if (tag != null && tag.trim().isNotEmpty) {
      queryParameters['tag'] = tag.trim();
    }

    if (queryParameters.isEmpty) {
      throw ArgumentError('Either orderId or tag is required.');
    }

    final query = Uri(queryParameters: queryParameters).query;

    return _get('/order/history?$query', accessToken);
  }
}

class _Timeframe {
  final String unit;
  final int interval;

  const _Timeframe({
    required this.unit,
    required this.interval,
  });
}
