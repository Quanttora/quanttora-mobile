import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  final String _baseUrl =
      dotenv.env['API_BASE_URL']!;

  Future<Map<String, dynamic>> get(
    String path,
  ) async {
    final response = await http.get(
      Uri.parse("$_baseUrl$path"),
      headers: const {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        "API Error ${response.statusCode}",
      );
    }

    return jsonDecode(response.body)
        as Map<String, dynamic>;
  }
}
  Future<List<dynamic>> getList(
    String path,
  ) async {
    final response = await http.get(
      Uri.parse("$_baseUrl$path"),
      headers: const {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        "API Error ${response.statusCode}",
      );
    }

    return jsonDecode(response.body)
        as List<dynamic>;
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse("$_baseUrl$path"),
      headers: const {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        "API Error ${response.statusCode}",
      );
    }

    return jsonDecode(response.body)
        as Map<String, dynamic>;
  }
    Future<bool> isServerAlive() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/market/status"),
        headers: const {
          "Content-Type": "application/json",
        },
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}