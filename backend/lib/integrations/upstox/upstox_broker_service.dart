import 'dart:convert';

import 'package:http/http.dart' as http;

class UpstoxBrokerService {
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
    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _headers(accessToken),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getFunds(
    String accessToken,
  ) async {
    return _get(
      '/user/get-funds-and-margin',
      accessToken,
    );
  }

  Future<Map<String, dynamic>> getProfile(
    String accessToken,
  ) async {
    return _get(
      '/user/profile',
      accessToken,
    );
  }

  Future<Map<String, dynamic>> getHoldings(
    String accessToken,
  ) async {
    return _get(
      '/portfolio/long-term-holdings',
      accessToken,
    );
  }

  Future<Map<String, dynamic>> getPositions(
    String accessToken,
  ) async {
    return _get(
      '/portfolio/short-term-positions',
      accessToken,
    );
  }

  Future<Map<String, dynamic>> getOrderBook(
    String accessToken,
  ) async {
    return _get(
      '/order/retrieve-all',
      accessToken,
    );
  }

  Future<Map<String, dynamic>> getTradeBook(
    String accessToken,
  ) async {
    return _get(
      '/order/trades/get-trades-for-day',
      accessToken,
    );
  }

  Future<Map<String, dynamic>> getQuotes(
    String accessToken,
    String instrumentKey,
  ) async {
    return _get(
      '/market-quote/quotes?instrument_key=$instrumentKey',
      accessToken,
    );
  }
}