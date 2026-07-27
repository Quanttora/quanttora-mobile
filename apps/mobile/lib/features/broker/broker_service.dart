import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class BrokerService {
  static const String baseUrl = 'http://localhost:8080';

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await http
        .get(Uri.parse('$baseUrl/broker/dashboard'))
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Unable to load dashboard');
    }

    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getHoldings() async {
    final dashboard = await getDashboard();

    if (dashboard["holdings"] is Map &&
        dashboard["holdings"]["data"] is List) {
      return dashboard["holdings"]["data"];
    }

    return [];
  }

  Future<List<dynamic>> getPositions() async {
    final dashboard = await getDashboard();

    if (dashboard["positions"] is Map &&
        dashboard["positions"]["data"] is List) {
      return dashboard["positions"]["data"];
    }

    return [];
  }

  Future<List<dynamic>> getOrders() async {
    final dashboard = await getDashboard();

    if (dashboard["orders"] is Map &&
        dashboard["orders"]["data"] is List) {
      return dashboard["orders"]["data"];
    }

    return [];
  }

  Future<List<dynamic>> getTrades() async {
    final dashboard = await getDashboard();

    if (dashboard["trades"] is Map &&
        dashboard["trades"]["data"] is List) {
      return dashboard["trades"]["data"];
    }

    return [];
  }

  Future<Map<String, dynamic>> refreshDashboard() async {
    return await getDashboard();
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
        final dashboard = await getDashboard();

        if (dashboard["connected"] == true) {
          return dashboard;
        }
      } catch (_) {}

      await Future.delayed(
        const Duration(seconds: 2),
      );
    }

    throw Exception("Connection timed out");
  }
}