import 'dart:convert';
import 'dart:io';

import 'package:backend/interfaces/broker_market_interface.dart';
import 'package:http/http.dart' as http;

class ZerodhaBrokerService implements BrokerMarketInterface {
  static const String _apiBaseUrl = 'https://api.kite.trade';

  String get _apiKey {
    final processValue =
        Platform.environment['ZERODHA_API_KEY']?.trim() ?? '';

    if (processValue.isNotEmpty) {
      return processValue;
    }

    final envFile = File('.env');

    if (!envFile.existsSync()) {
      throw StateError(
        'Backend .env file was not found. '
        'Expected .env in the backend working directory.',
      );
    }

    final lines = envFile.readAsLinesSync();

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        continue;
      }

      final separatorIndex = trimmed.indexOf('=');

      if (separatorIndex <= 0) {
        continue;
      }

      final key = trimmed.substring(0, separatorIndex).trim();

      if (key != 'ZERODHA_API_KEY') {
        continue;
      }

      var value = trimmed.substring(separatorIndex + 1).trim();

      if (value.length >= 2) {
        final first = value[0];
        final last = value[value.length - 1];

        if ((first == '"' && last == '"') ||
            (first == "'" && last == "'")) {
          value = value.substring(1, value.length - 1).trim();
        }
      }

      if (value.isNotEmpty) {
        return value;
      }
    }

    throw StateError(
      'ZERODHA_API_KEY was not found in the backend .env file.',
    );
  }

  Map<String, String> _headers(String accessToken) {
    final apiKey = _apiKey;
    final token = accessToken.trim();

    if (token.isEmpty) {
      throw StateError('Zerodha access token is empty.');
    }

    return {
      'X-Kite-Version': '3',
      'Authorization': 'token $apiKey:$token',
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
        'Zerodha $method failed (${response.statusCode}): ${response.body}',
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
    return _asMap(await _request('GET', '/user/margins', accessToken));
  }

  @override
  Future<Map<String, dynamic>> getProfile(String accessToken) async {
    return _asMap(await _request('GET', '/user/profile', accessToken));
  }

  @override
  Future<Map<String, dynamic>> getHoldings(String accessToken) async {
    return _asMap(await _request('GET', '/portfolio/holdings', accessToken));
  }

  @override
  Future<Map<String, dynamic>> getPositions(String accessToken) async {
    return _asMap(await _request('GET', '/portfolio/positions', accessToken));
  }

  @override
  Future<Map<String, dynamic>> getOrderBook(String accessToken) async {
    return _asMap(await _request('GET', '/orders', accessToken));
  }

  @override
  Future<Map<String, dynamic>> getTradeBook(String accessToken) async {
    return _asMap(await _request('GET', '/trades', accessToken));
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
        .map((instrument) => 'i=${Uri.encodeQueryComponent(instrument)}')
        .join('&');

    if (query.isEmpty) {
      throw ArgumentError('At least one instrument is required.');
    }

    return _asMap(await _request('GET', '/quote?$query', accessToken));
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
    final instrumentToken = _resolveHistoricalInstrumentToken(instrumentKey);

    final from = _parseDate(fromDate, 'fromDate');
    final to = _parseDate(toDate, 'toDate');

    if (from.isAfter(to)) {
      throw ArgumentError('fromDate cannot be after toDate.');
    }

    final chunkDays = _historicalChunkDays(intervalValue);
    final allCandles = <dynamic>[];
    var chunkStart = from;

    while (!chunkStart.isAfter(to)) {
      var chunkEnd = chunkStart.add(Duration(days: chunkDays));

      if (chunkEnd.isAfter(to)) {
        chunkEnd = to;
      }

      final endpoint = '/instruments/historical/'
          '$instrumentToken/'
          '$intervalValue'
          '?from=${Uri.encodeQueryComponent(_formatDate(chunkStart))}'
          '&to=${Uri.encodeQueryComponent(_formatDate(chunkEnd))}';

      final response = _asMap(
        await _request('GET', endpoint, accessToken),
      );

      final data = response['data'];
      if (data is Map) {
        final candles = data['candles'];
        if (candles is List) {
          allCandles.addAll(candles);
        }
      }

      if (chunkEnd.isAtSameMomentAs(to)) {
        break;
      }

      chunkStart = chunkEnd.add(const Duration(days: 1));
    }

    final deduplicated = <String, dynamic>{};
    for (final candle in allCandles) {
      if (candle is List && candle.isNotEmpty) {
        deduplicated[candle[0].toString()] = candle;
      }
    }

    final candles = deduplicated.values.toList();
    candles.sort((a, b) => a[0].toString().compareTo(b[0].toString()));

    return <String, dynamic>{
      'status': 'success',
      'data': <String, dynamic>{
        'candles': candles,
      },
    };
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

  String _resolveHistoricalInstrumentToken(String value) {
    final normalized = value.trim();

    if (RegExp(r'^\d+$').hasMatch(normalized)) {
      return normalized;
    }

    final key = normalized.toUpperCase();

    const tokenMap = <String, String>{
      'NSE_INDEX|NIFTY 50': '256265',
      'NSE_INDEX|NIFTY BANK': '260105',
      'BSE_INDEX|SENSEX': '265',
      'NSE:NIFTY 50': '256265',
      'NSE:NIFTY BANK': '260105',
      'BSE:SENSEX': '265',
    };

    final token = tokenMap[key];
    if (token != null) {
      return token;
    }

    throw ArgumentError(
      'Unsupported Zerodha historical instrument: $value. '
      'Pass a Zerodha instrument token or a supported index key.',
    );
  }

  int _historicalChunkDays(String interval) {
    switch (interval) {
      case 'minute':
        return 60;
      case '3minute':
      case '5minute':
      case '10minute':
        return 100;
      case '15minute':
      case '30minute':
        return 200;
      case '60minute':
        return 400;
      case 'day':
      case 'week':
      case 'month':
        return 2000;
      default:
        return 60;
    }
  }

  DateTime _parseDate(String value, String fieldName) {
    try {
      return DateTime.parse(value.trim());
    } catch (_) {
      throw ArgumentError(
        '$fieldName must use YYYY-MM-DD format: $value',
      );
    }
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
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
        throw ArgumentError('Unsupported Zerodha interval: $value');
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    throw Exception('Invalid Zerodha response format.');
  }
}
