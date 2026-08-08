import '../../../core/network/api_client.dart';
import '../models/home_dashboard_data.dart';
import 'home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  @override
  Future<HomeDashboardData> getDashboard() async {
    final json = await _apiClient.get('/dashboard/home');

    return HomeDashboardData(
      userName: _stringValue(json, 'userName'),
      portfolioValue: _doubleValue(json, 'portfolioValue'),
      todayPnL: _doubleValue(json, 'todayPnL'),
      todayPnLPercent: _doubleValue(json, 'todayPnLPercent'),
      isProfit: _boolValue(json, 'isProfit'),
      aiScore: _intValue(json, 'aiScore'),
      marketOverview: _parseMarketOverview(json['marketOverview']),
      marketNews: _parseMarketNews(json['marketNews']),
    );
  }

  List<MarketIndexData> _parseMarketOverview(dynamic value) {
    if (value == null) {
      return const <MarketIndexData>[];
    }

    if (value is! List) {
      throw const FormatException('marketOverview must be a JSON list.');
    }

    return value
        .map((item) {
          if (item is! Map) {
            throw const FormatException('Invalid marketOverview item.');
          }

          final data = Map<String, dynamic>.from(item);

          return MarketIndexData(
            name: _requiredString(data, 'name'),
            value: _requiredDouble(data, 'value'),
            change: _requiredDouble(data, 'change'),
            changePercent: _requiredDouble(data, 'changePercent'),
          );
        })
        .toList(growable: false);
  }

  List<MarketNewsData> _parseMarketNews(dynamic value) {
    if (value == null) {
      return const <MarketNewsData>[];
    }

    if (value is! List) {
      throw const FormatException('marketNews must be a JSON list.');
    }

    return value
        .map((item) {
          if (item is! Map) {
            throw const FormatException('Invalid marketNews item.');
          }

          final data = Map<String, dynamic>.from(item);

          return MarketNewsData(
            title: _requiredString(data, 'title'),
            source: _requiredString(data, 'source'),
            time: _requiredString(data, 'time'),
            highImpact: _requiredBool(data, 'highImpact'),
            url: _requiredString(data, 'url'),
          );
        })
        .toList(growable: false);
  }

  String _stringValue(Map<String, dynamic> json, String key) {
    final value = json[key];

    if (value == null) {
      return '';
    }

    return value.toString();
  }

  double _doubleValue(Map<String, dynamic> json, String key) {
    final value = json[key];

    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    final parsed = double.tryParse(value.toString());

    if (parsed == null) {
      throw FormatException('$key must be numeric.');
    }

    return parsed;
  }

  int _intValue(Map<String, dynamic> json, String key) {
    final value = json[key];

    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toInt();
    }

    final parsed = int.tryParse(value.toString());

    if (parsed == null) {
      throw FormatException('$key must be an integer.');
    }

    return parsed;
  }

  bool _boolValue(Map<String, dynamic> json, String key) {
    final value = json[key];

    if (value == null) {
      return false;
    }

    if (value is bool) {
      return value;
    }

    throw FormatException('$key must be boolean.');
  }

  String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];

    if (value == null || value.toString().trim().isEmpty) {
      throw FormatException('$key is required.');
    }

    return value.toString();
  }

  double _requiredDouble(Map<String, dynamic> json, String key) {
    final value = json[key];

    if (value is num) {
      return value.toDouble();
    }

    final parsed = double.tryParse(value?.toString() ?? '');

    if (parsed == null) {
      throw FormatException('$key must be numeric.');
    }

    return parsed;
  }

  bool _requiredBool(Map<String, dynamic> json, String key) {
    final value = json[key];

    if (value is bool) {
      return value;
    }

    throw FormatException('$key must be boolean.');
  }
}
