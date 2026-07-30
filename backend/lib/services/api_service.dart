import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  static const String baseUrl = 'http://localhost:8080';

  Future<Map<String, dynamic>> get(
    String endpoint,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getMarketDashboard() {
    return get('/market/dashboard');
  }

  Future<Map<String, dynamic>> getMarketQuotes() {
    return get('/market/quotes');
  }

  Future<Map<String, dynamic>> getBrokerDashboard() {
    return get('/broker/dashboard');
  }
}