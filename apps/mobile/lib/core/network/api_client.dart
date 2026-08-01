import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static const Duration _timeout = Duration(seconds: 15);

  String get _baseUrl {
    final value = dotenv.env['API_BASE_URL']?.trim();

    if (value == null || value.isEmpty) {
      throw StateError('API_BASE_URL is not configured in .env');
    }

    if (value.endsWith('/')) {
      return value.substring(0, value.length - 1);
    }

    return value;
  }

  Uri _buildUri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    return Uri.parse('$_baseUrl$normalizedPath');
  }

  Map<String, String> get _headers => const {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Future<Map<String, dynamic>> get(String path) async {
    final response = await http
        .get(_buildUri(path), headers: _headers)
        .timeout(_timeout);

    return _decodeMapResponse(response);
  }

  Future<List<dynamic>> getList(String path) async {
    final response = await http
        .get(_buildUri(path), headers: _headers)
        .timeout(_timeout);

    _validateResponse(response);

    if (response.body.trim().isEmpty) {
      return <dynamic>[];
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw const FormatException('Expected API response to be a JSON list.');
    }

    return decoded;
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http
        .post(_buildUri(path), headers: _headers, body: jsonEncode(body))
        .timeout(_timeout);

    return _decodeMapResponse(response);
  }

  Future<bool> isServerAlive() async {
    try {
      final response = await http
          .get(_buildUri('/market/status'), headers: _headers)
          .timeout(_timeout);

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _decodeMapResponse(http.Response response) {
    _validateResponse(response);

    if (response.body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw const FormatException('Expected API response to be a JSON object.');
    }

    return Map<String, dynamic>.from(decoded);
  }

  void _validateResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    String message = 'API request failed (${response.statusCode}).';

    if (response.body.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map) {
          final apiMessage = decoded['message'] ?? decoded['error'];

          if (apiMessage != null && apiMessage.toString().trim().isNotEmpty) {
            message = apiMessage.toString();
          }
        }
      } catch (_) {
        // Keep the safe HTTP status message.
      }
    }

    throw ApiException(statusCode: response.statusCode, message: message);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() {
    return 'ApiException($statusCode): $message';
  }
}
