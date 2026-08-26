import 'dart:convert';

import 'package:shelf/shelf.dart';

class ApiResponse {
  ApiResponse._();

  static Response success({
    required Map<String, dynamic> data,
    int statusCode = 200,
  }) {
    return Response(
      statusCode,
      body: jsonEncode({
        'success': true,
        'data': data,
      }),
      headers: {
        'content-type': 'application/json',
      },
    );
  }

  static Response error({
    required int statusCode,
    required String code,
    required String message,
  }) {
    return Response(
      statusCode,
      body: jsonEncode({
        'success': false,
        'error': {
          'code': code,
          'message': message,
        },
      }),
      headers: {
        'content-type': 'application/json',
      },
    );
  }

  static Future<Map<String, dynamic>?> readJsonBody(
    Request request,
  ) async {
    try {
      final body = await request.readAsString();

      if (body.trim().isEmpty) {
        return null;
      }

      final decoded = jsonDecode(body);

      if (decoded is! Map) {
        return null;
      }

      return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return null;
    }
  }
}