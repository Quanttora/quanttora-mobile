import 'dart:convert';

import 'package:backend/interfaces/broker_market_interface.dart';
import 'package:http/http.dart' as http;

class ZerodhaBrokerService implements BrokerMarketInterface {
  static const String _apiBaseUrl = 'https://api.kite.trade';

  Map<String, String> _headers(String accessToken) {
    return {
      'X-Kite-Version': '3',
      'Authorization': 'token $accessToken',
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
  }

  Future<dynamic> _request(
    String method,
    String endpoint,
    String accessToken, {
    Map<String, String>? body,
  }) async {
    final url = Uri.parse('$_apiBaseUrl$endpoint');
    final headers = _headers(accessToken);

    late http.Response response;

    switch (method) {
      case 'GET':
        response = await http
            .get(url, headers: headers)
            .timeout(const Duration(seconds: 15));
        break;

      case 'POST':
        response = await http
            .post(url, headers: headers, body: body)
            .timeout(const Duration(seconds: 15));
        break;

      case 'PUT':
        response = await http
            .put(url, headers: headers, body: body)
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
        'Zerodha $method failed '
        '(${response.statusCode}): ${response.body}',
      );
    }

    if (response.body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    return decoded;
  }

  @override
  Future<Map<String, dynamic>> getFunds(String accessToken) async {
    return _asMap(
      await _request('GET', '/user/margins', accessToken),
    );
  }

  @override
  Future<Map<String, dynamic>> getProfile(String accessToken) async {
    return _asMap(
      await _request('GET', '/user/profile', accessToken),
    );
  }

  @override
  Future<Map<String, dynamic>> getHoldings(String accessToken) async {
    return _asMap(
      await _request('GET', '/portfolio/holdings', accessToken),
    );
  }

  @override
  Future<Map<String, dynamic>> getPositions(String accessToken) async {
    return _asMap(
      await _request('GET', '/portfolio/positions', accessToken),
    );
  }

  @override
  Future<Map<String, dynamic>> getOrderBook(String accessToken) async {
    return _asMap(
      await _request('GET', '/orders', accessToken),
    );
  }

  @override
  Future<Map<String, dynamic>> getTradeBook(String accessToken) async {
    return _asMap(
      await _request('GET', '/trades', accessToken),
    );
  }

  @override
  Future<Map<String, dynamic>> getQuotes(
    String accessToken,
    String instrumentKeys,
  ) async {
    final instruments = instrumentKeys
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty);

    final query = instruments
        .map(
          (instrument) =>
              'i=${Uri.encodeQueryComponent(instrument)}',
        )
        .join('&');

    if (query.isEmpty) {
      throw ArgumentError('At least one instrument is required.');
    }

    return _asMap(
      await _request(
        'GET',
        '/quote?$query',
        accessToken,
      ),
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
    final intervalValue = _normalizeInterval(interval);

    final encodedToken =
        Uri.encodeComponent(instrumentKey.trim());

    return _asMap(
      await _request(
        'GET',
        '/instruments/historical/$encodedToken/'
        '$intervalValue'
        '?from=${Uri.encodeQueryComponent(fromDate)}'
        '&to=${Uri.encodeQueryComponent(toDate)}',
        accessToken,
      ),
    );
  }

  @override
  Future<Map<String, dynamic>> getIntradayCandles(
    String accessToken,
    String instrumentKey,
    String interval,
  ) async {
    throw UnsupportedError(
      'Zerodha intraday candles use the historical candle endpoint '
      'with the current trading-day date range.',
    );
  }

  String _normalizeInterval(String value) {
    final normalized = value.trim().toLowerCase();

    switch (normalized) {
      case 'minute':
      case '1minute':
      case '1m':
        return 'minute';

      case '3minute':
      case '3m':
        return '3minute';

      case '5minute':
      case '5m':
        return '5minute';

      case '10minute':
      case '10m':
        return '10minute';

      case '15minute':
      case '15m':
        return '15minute';

      case '30minute':
      case '30m':
        return '30minute';

      case '60minute':
      case '1hour':
      case '1h':
        return '60minute';

      case 'day':
      case '1day':
      case '1d':
        return 'day';

      case 'week':
      case '1week':
      case '1w':
        return 'week';

      case 'month':
      case '1month':
      case '1mo':
        return 'month';

      default:
        throw ArgumentError(
          'Unsupported Zerodha interval: $value',
        );
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    throw Exception(
      'Invalid Zerodha response format.',
    );
  }
}
