import 'dart:convert';

import 'package:backend/interfaces/broker_market_interface.dart';
import 'package:http/http.dart' as http;

class UpstoxBrokerService implements BrokerMarketInterface {
  static const String _baseUrl = 'https://api.upstox.com/v2';

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

    print('');
    print('============================');
    print('GET : $url');
    print('============================');

    final response = await http.get(
      url,
      headers: _headers(accessToken),
    );

    print('STATUS : ${response.statusCode}');
    print('BODY   : ${response.body}');
    print('============================');
    print('');

    if (response.statusCode != 200) {
      throw Exception(
        'HTTP ${response.statusCode}\n${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
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
}