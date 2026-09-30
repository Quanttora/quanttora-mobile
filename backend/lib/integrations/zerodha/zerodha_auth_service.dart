import 'dart:convert';

import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class ZerodhaAuthService {
  final DotEnv _env = DotEnv()..load();

  String get apiKey => _env['ZERODHA_API_KEY'] ?? '';

  String get apiSecret => _env['ZERODHA_API_SECRET'] ?? '';

  String get redirectUri => _env['ZERODHA_REDIRECT_URI'] ?? '';

  String getLoginUrl() {
    return Uri.https(
      'kite.zerodha.com',
      '/connect/login',
      {
        'v': '3',
        'api_key': apiKey,
      },
    ).toString();
  }

  Future<Map<String, dynamic>> exchangeRequestToken({
    required String requestToken,
  }) async {
    final checksum = _sha256(
      '$apiKey$requestToken$apiSecret',
    );

    final response = await http.post(
      Uri.parse(
        'https://api.kite.trade/session/token',
      ),
      headers: {
        'X-Kite-Version': '3',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'api_key': apiKey,
        'request_token': requestToken,
        'checksum': checksum,
      },
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Zerodha authentication failed '
        '(${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception(
        'Invalid Zerodha authentication response.',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }

  String _sha256(String value) {
    return sha256.convert(utf8.encode(value)).toString();
  }
}


