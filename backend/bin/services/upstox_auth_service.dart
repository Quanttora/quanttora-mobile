import 'dart:convert';

import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart' as http;

class UpstoxAuthService {
  final DotEnv _env = DotEnv()..load();

  String get clientId => _env['UPSTOX_CLIENT_ID'] ?? '';

  String get clientSecret => _env['UPSTOX_CLIENT_SECRET'] ?? '';

  String get redirectUri => _env['UPSTOX_REDIRECT_URI'] ?? '';

  String getLoginUrl() {
    return Uri.https(
      'api.upstox.com',
      '/v2/login/authorization/dialog',
      {
        'response_type': 'code',
        'client_id': clientId,
        'redirect_uri': redirectUri,
      },
    ).toString();
  }

  Future<Map<String, dynamic>> exchangeCode({
    required String code,
  }) async {
    final response = await http.post(
      Uri.parse(
        'https://api.upstox.com/v2/login/authorization/token',
      ),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'code': code,
        'client_id': clientId,
        'client_secret': clientSecret,
        'redirect_uri': redirectUri,
        'grant_type': 'authorization_code',
      },
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}