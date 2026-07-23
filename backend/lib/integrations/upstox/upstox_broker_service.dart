import 'dart:convert';

import 'package:http/http.dart' as http;

class UpstoxBrokerService {
  Future<Map<String, dynamic>> getFunds(
    String accessToken,
  ) async {
    final response = await http.get(
      Uri.parse(
        'https://api.upstox.com/v2/user/get-funds-and-margin',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    return jsonDecode(response.body);
  }
}