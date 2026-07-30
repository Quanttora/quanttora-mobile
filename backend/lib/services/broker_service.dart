import 'dart:async';

import 'package:mobile/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class BrokerService {
  static const String baseUrl = 'http://localhost:8080';

  final ApiService _api = ApiService.instance;

  Future<Map<String, dynamic>> getDashboard() =>
      _api.getBrokerDashboard();

  Future<Map<String, dynamic>> getMarketIndices() =>
      _api.getMarketDashboard();

  List<dynamic> extractHoldings(Map<String, dynamic> dashboard) {
    if (dashboard["holdings"] is Map &&
        dashboard["holdings"]["data"] is List) {
      return dashboard["holdings"]["data"];
    }
    return [];
  }

  List<dynamic> extractPositions(Map<String, dynamic> dashboard) {
    if (dashboard["positions"] is Map &&
        dashboard["positions"]["data"] is List) {
      return dashboard["positions"]["data"];
    }
    return [];
  }

  List<dynamic> extractOrders(Map<String, dynamic> dashboard) {
    if (dashboard["orders"] is Map &&
        dashboard["orders"]["data"] is List) {
      return dashboard["orders"]["data"];
    }
    return [];
  }

  List<dynamic> extractTrades(Map<String, dynamic> dashboard) {
    if (dashboard["trades"] is Map &&
        dashboard["trades"]["data"] is List) {
      return dashboard["trades"]["data"];
    }
    return [];
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

  Future<void> disconnectBroker() async {
    await _api.get('/broker/disconnect');
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

      await Future.delayed(const Duration(seconds: 2));
    }

    throw Exception("Connection timed out");
  }
}