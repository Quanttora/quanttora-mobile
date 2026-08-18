import 'dart:convert';

import 'package:backend/core/config/app_config.dart';
import 'package:http/http.dart' as http;

class UpstoxAuthService {
  String getLoginUrl() {
    return Uri.https('api.upstox.com', '/v2/login/authorization/dialog', {
      'response_type': 'code',
      'client_id': AppConfig.upstoxClientId,
      'redirect_uri': AppConfig.upstoxRedirectUri,
    }).toString();
  }

  Future<Map<String, dynamic>> exchangeCode({required String code}) async {
    if (code.trim().isEmpty) {
      throw Exception('Upstox authorization code is empty.');
    }

    final response = await http
        .post(
          Uri.parse('https://api.upstox.com/v2/login/authorization/token'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'code': code,
            'client_id': AppConfig.upstoxClientId,
            'client_secret': AppConfig.upstoxClientSecret,
            'redirect_uri': AppConfig.upstoxRedirectUri,
            'grant_type': 'authorization_code',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String errorDetails = response.body.trim();

      if (errorDetails.isEmpty) {
        errorDetails = 'No error details returned by Upstox.';
      }

      throw Exception(
        'Upstox token exchange failed '
        '(${response.statusCode}): '
        '$errorDetails',
      );
    }

    if (response.body.trim().isEmpty) {
      throw Exception('Upstox returned an empty token response.');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception('Invalid Upstox token response.');
    }

    final data = Map<String, dynamic>.from(decoded);

    final accessToken = data['access_token']?.toString() ?? '';

    if (accessToken.isEmpty) {
      throw Exception('Upstox did not return an access token.');
    }

    return data;
  }
}
