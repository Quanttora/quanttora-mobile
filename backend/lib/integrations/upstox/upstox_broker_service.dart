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
    final url = Uri.parse('$_baseUrl$endpoint');

    print('');
    print('============================');
    print('GET : $url');
    print('TOKEN : ${accessToken.substring(0, accessToken.length > 20 ? 20 : accessToken.length)}...');
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

  Future<Map<String, dynamic>> getFunds(String accessToken) =>
      _get('/user/get-funds-and-margin', accessToken);

  Future<Map<String, dynamic>> getProfile(String accessToken) =>
      _get('/user/profile', accessToken);

  Future<Map<String, dynamic>> getHoldings(String accessToken) =>
      _get('/portfolio/long-term-holdings', accessToken);

  Future<Map<String, dynamic>> getPositions(String accessToken) =>
      _get('/portfolio/short-term-positions', accessToken);

  Future<Map<String, dynamic>> getOrderBook(String accessToken) =>
      _get('/order/retrieve-all', accessToken);

  Future<Map<String, dynamic>> getTradeBook(String accessToken) =>
      _get('/order/trades/get-trades-for-day', accessToken);

  Future<Map<String, dynamic>> getQuotes(
    String accessToken,
    String instrumentKey,
  ) =>
      _get(
        '/market-quote/quotes?instrument_key=$instrumentKey',
        accessToken,
      );

  Future<Map<String, dynamic>> getHistoricalCandles(
    String accessToken,
    String instrumentKey,
    String interval,
    String toDate,
    String fromDate,
  ) =>
      _get(
        '/historical-candle/$instrumentKey/$interval/$toDate/$fromDate',
        accessToken,
      );
}