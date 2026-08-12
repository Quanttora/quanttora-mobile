import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class BrokerService {
  static const String baseUrl =
      'http://localhost:8080';

  Future<Map<String, dynamic>> _get(
    String endpoint,
  ) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl$endpoint'),
        )
        .timeout(
          const Duration(seconds: 20),
        );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final decoded = jsonDecode(
      response.body,
    );

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'Invalid server response',
      );
    }

    return decoded;
  }

  Future<Map<String, dynamic>> getDashboard() =>
      _get('/broker/dashboard');

  Future<Map<String, dynamic>> getMarketIndices() =>
      _get('/broker/market-indices');

  Future<Map<String, dynamic>> getBrokerStatus() =>
      _get('/broker/status');

  List<dynamic> extractHoldings(
    Map<String, dynamic> dashboard,
  ) {
    if (dashboard["holdings"] is Map &&
        dashboard["holdings"]["data"] is List) {
      return dashboard["holdings"]["data"];
    }

    return [];
  }

  List<dynamic> extractPositions(
    Map<String, dynamic> dashboard,
  ) {
    if (dashboard["positions"] is Map &&
        dashboard["positions"]["data"] is List) {
      return dashboard["positions"]["data"];
    }

    return [];
  }

  List<dynamic> extractOrders(
    Map<String, dynamic> dashboard,
  ) {
    if (dashboard["orders"] is Map &&
        dashboard["orders"]["data"] is List) {
      return dashboard["orders"]["data"];
    }

    return [];
  }

  List<dynamic> extractTrades(
    Map<String, dynamic> dashboard,
  ) {
    if (dashboard["trades"] is Map &&
        dashboard["trades"]["data"] is List) {
      return dashboard["trades"]["data"];
    }

    return [];
  }

  Future<void> connectBroker() async {
    final uri = Uri.parse(
      '$baseUrl/auth/upstox/login',
    );

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      throw Exception(
        'Unable to launch Upstox Login',
      );
    }
  }

  Future<void> disconnectBroker() async {
    final response = await http
        .post(
          Uri.parse(
            '$baseUrl/broker/disconnect',
          ),
        )
        .timeout(
          const Duration(seconds: 20),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'Unable to disconnect broker',
      );
    }
  }

  Future<Map<String, dynamic>> waitForConnection() async {
    const maxAttempts = 30;

    for (int i = 0; i < maxAttempts; i++) {
      try {
        final status =
            await getBrokerStatus();

        final connected =
            status['connected'] == true;

        final broker =
            status['broker']?.toString();

        if (connected &&
            broker != null &&
            broker.isNotEmpty) {
          return status;
        }
      } catch (_) {}

      await Future.delayed(
        const Duration(seconds: 2),
      );
    }

    throw Exception(
      'Connection timed out',
    );
  }
}