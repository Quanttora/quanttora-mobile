import 'dart:convert';

import 'package:backend/core/config/app_config.dart';
import 'package:http/http.dart' as http;

class UpstoxAuthService {
  String getLoginUrl() {
    return Uri.https(
      'api.upstox.com',
      '/v2/login/authorization/dialog',
      {
        'response_type': 'code',
        'client_id': AppConfig.upstoxClientId,
        'redirect_uri': AppConfig.upstoxRedirectUri,
      },
    ).toString();
  }

  Future<Map<String, dynamic>> exchangeCode({
    required String code,
  }) async {
    print('');
    print('========================================');
    print('UPSTOX TOKEN EXCHANGE');
    print('========================================');
    print('Code            : $code');
    print('Client ID       : ${AppConfig.upstoxClientId}');
    print('Client Secret   : ${AppConfig.upstoxClientSecret}');
    print('Secret Length   : ${AppConfig.upstoxClientSecret.length}');
    print('Redirect URI    : ${AppConfig.upstoxRedirectUri}');
    print('========================================');
    print('');

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
        'client_id': AppConfig.upstoxClientId,
        'client_secret': AppConfig.upstoxClientSecret,
        'redirect_uri': AppConfig.upstoxRedirectUri,
        'grant_type': 'authorization_code',
      },
    );

    print('');
    print('========================================');
    print('UPSTOX RESPONSE');
    print('========================================');
    print('Status Code : ${response.statusCode}');
    print('Headers     : ${response.headers}');
    print('Body        : ${response.body}');
    print('========================================');
    print('');

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    print('');
    print('========================================');
    print('TOKEN RECEIVED');
    print('========================================');
    print('Access Token : ${data['access_token']}');
    print('========================================');
    print('');

    return data;
  }
}