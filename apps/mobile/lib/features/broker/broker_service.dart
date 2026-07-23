import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class BrokerService {
  static const String baseUrl = 'http://localhost:8080';

  Future<Map<String, dynamic>> getBrokerStatus() async {
    final response = await http
        .get(Uri.parse('$baseUrl/broker/status'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Unable to connect to backend');
    }

    return jsonDecode(response.body);
  }

  Future<void> connectBroker() async {
    final uri = Uri.parse('$baseUrl/auth/upstox/login');

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      throw Exception('Unable to launch Upstox Login');
    }
  }

  Future<Map<String, dynamic>> waitForConnection() async {
    const maxAttempts = 30;

    for (int i = 0; i < maxAttempts; i++) {
      try {
        final status = await getBrokerStatus();

        if (status['connected'] == true) {
          return status;
        }
      } catch (_) {}

      await Future.delayed(const Duration(seconds: 2));
    }

    throw Exception('Connection timed out');
  }

  Future<Map<String, dynamic>> getFunds() async {
    final response = await http
        .get(Uri.parse('$baseUrl/broker/funds'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Unable to fetch funds');
    }

    return jsonDecode(response.body);
  }
}