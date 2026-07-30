import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_constants.dart';
import '../models/home_dashboard_data.dart';
import 'home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    http.Client? client,
  }) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<HomeDashboardData> getDashboard() async {
    final response = await _client.get(
      Uri.parse(
        '${ApiConstants.baseUrl}/dashboard/home',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to load dashboard');
    }

    final json =
        jsonDecode(response.body) as Map<String, dynamic>;

    return HomeDashboardData(
      userName: json['userName'] ?? '',
      portfolioValue:
          (json['portfolioValue'] as num).toDouble(),
      todayPnL:
          (json['todayPnL'] as num).toDouble(),
      todayPnLPercent:
          (json['todayPnLPercent'] as num).toDouble(),
      isProfit: json['isProfit'] ?? true,
      aiScore: json['aiScore'] ?? 0,
      marketOverview: (json['marketOverview'] as List)
          .map(
            (e) => MarketIndexData(
              name: e['name'],
              value: (e['value'] as num).toDouble(),
              change: (e['change'] as num).toDouble(),
              changePercent:
                  (e['changePercent'] as num).toDouble(),
            ),
          )
          .toList(),
      marketNews: (json['marketNews'] as List)
          .map(
            (e) => MarketNewsData(
              title: e['title'],
              source: e['source'],
              time: e['time'],
              highImpact: e['highImpact'],
              url: e['url'],
            ),
          )
          .toList(),
    );
  }
}