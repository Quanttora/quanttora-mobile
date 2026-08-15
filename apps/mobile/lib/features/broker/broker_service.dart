import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_client.dart';

class BrokerService {
  BrokerService();

  static final BrokerService instance = BrokerService();

  final ApiClient _api = ApiClient.instance;

  Future<Map<String, dynamic>> getDashboard() {
    return _api.get('/broker/dashboard');
  }

  Future<Map<String, dynamic>> getMarketIndices() {
    return _api.get('/broker/market-indices');
  }

  Future<Map<String, dynamic>> getBrokerStatus() {
    return _api.get('/broker/status');
  }

  Future<Map<String, dynamic>> getOrders() {
    return _api.get('/broker/orders');
  }

  Future<Map<String, dynamic>> getTrades() {
    return _api.get('/broker/trades');
  }

  Future<Map<String, dynamic>> getPositions() {
    return _api.get('/broker/positions');
  }

  Future<Map<String, dynamic>> getHoldings() {
    return _api.get('/broker/holdings');
  }

  Future<Map<String, dynamic>> getOrderDetails(String orderId) {
    return _api.get('/broker/orders/$orderId');
  }

  /// Fetches the live Upstox quote for an instrument.
  ///
  /// Example:
  /// NSE_INDEX|Nifty 50
  Future<Map<String, dynamic>> getQuote({required String instrumentKey}) {
    final encodedInstrument = Uri.encodeQueryComponent(instrumentKey);

    return _api.get('/broker/quotes?instrumentKey=$encodedInstrument');
  }

  Future<Map<String, dynamic>> getHistoricalCandles({
    required String instrumentKey,
    required String fromDate,
    required String toDate,
    String interval = 'day',
  }) {
    final encodedInstrument = Uri.encodeQueryComponent(instrumentKey);

    return _api.get(
      '/broker/history'
      '?instrumentKey=$encodedInstrument'
      '&fromDate=$fromDate'
      '&toDate=$toDate'
      '&interval=$interval',
    );
  }

  Future<Map<String, dynamic>> placePaperTrade({
    required String instrumentToken,
    required int quantity,
    required String product,
    required String validity,
    required double price,
    required String orderType,
    required String transactionType,
    required bool constitutionPassed,
    required bool strategyPolicyPassed,
    required int aiConfidence,
    required int minimumAiScore,
    required int tradesToday,
    required int maxTradesPerDay,
    required double riskReward,
    required double minimumRiskReward,
  }) {
    return _api.post('/broker/orders', {
      'instrumentToken': instrumentToken,
      'quantity': quantity,
      'product': product,
      'validity': validity,
      'price': price,
      'orderType': orderType,
      'transactionType': transactionType,
      'constitutionPassed': constitutionPassed,
      'strategyPolicyPassed': strategyPolicyPassed,
      'aiConfidence': aiConfidence,
      'minimumAiScore': minimumAiScore,
      'tradesToday': tradesToday,
      'maxTradesPerDay': maxTradesPerDay,
      'riskReward': riskReward,
      'minimumRiskReward': minimumRiskReward,
      'paperTrade': true,
    });
  }

  Future<Map<String, dynamic>> placeLiveTrade({
    required String instrumentToken,
    required int quantity,
    required String product,
    required String validity,
    required double price,
    required String orderType,
    required String transactionType,
    required bool constitutionPassed,
    required bool strategyPolicyPassed,
    required int aiConfidence,
    required int minimumAiScore,
    required int tradesToday,
    required int maxTradesPerDay,
    required double riskReward,
    required double minimumRiskReward,
  }) {
    return _api.post('/broker/orders', {
      'instrumentToken': instrumentToken,
      'quantity': quantity,
      'product': product,
      'validity': validity,
      'price': price,
      'orderType': orderType,
      'transactionType': transactionType,
      'constitutionPassed': constitutionPassed,
      'strategyPolicyPassed': strategyPolicyPassed,
      'aiConfidence': aiConfidence,
      'minimumAiScore': minimumAiScore,
      'tradesToday': tradesToday,
      'maxTradesPerDay': maxTradesPerDay,
      'riskReward': riskReward,
      'minimumRiskReward': minimumRiskReward,
      'paperTrade': false,
    });
  }

  Future<Map<String, dynamic>> modifyOrder({
    required String orderId,
    required int quantity,
    required double price,
    required String validity,
    required String orderType,
    double triggerPrice = 0,
    int disclosedQuantity = 0,
    int marketProtection = -1,
  }) {
    return _api.put('/broker/orders/$orderId', {
      'quantity': quantity,
      'price': price,
      'validity': validity,
      'orderType': orderType,
      'triggerPrice': triggerPrice,
      'disclosedQuantity': disclosedQuantity,
      'marketProtection': marketProtection,
    });
  }

  Future<Map<String, dynamic>> cancelOrder(String orderId) {
    return _api.delete('/broker/orders/$orderId');
  }

  Future<void> connectBroker() async {
    final uri = Uri.parse('http://localhost:8080/auth/upstox/login');

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched) {
      throw Exception('Unable to launch Upstox Login');
    }
  }

  Future<void> disconnectBroker() async {
    await _api.post('/broker/disconnect', {});
  }

  Future<Map<String, dynamic>> waitForConnection() async {
    const maxAttempts = 30;

    for (int i = 0; i < maxAttempts; i++) {
      try {
        final status = await getBrokerStatus();

        final connected = status['connected'] == true;

        final broker = status['broker']?.toString();

        if (connected && broker != null && broker.isNotEmpty) {
          return status;
        }
      } catch (_) {}

      await Future.delayed(const Duration(seconds: 2));
    }

    throw Exception('Connection timed out');
  }

  List<dynamic> extractHoldings(Map<String, dynamic> dashboard) {
    if (dashboard['holdings'] is Map && dashboard['holdings']['data'] is List) {
      return dashboard['holdings']['data'];
    }

    return [];
  }

  List<dynamic> extractPositions(Map<String, dynamic> dashboard) {
    if (dashboard['positions'] is Map &&
        dashboard['positions']['data'] is List) {
      return dashboard['positions']['data'];
    }

    return [];
  }

  List<dynamic> extractOrders(Map<String, dynamic> dashboard) {
    if (dashboard['orders'] is Map && dashboard['orders']['data'] is List) {
      return dashboard['orders']['data'];
    }

    return [];
  }

  List<dynamic> extractTrades(Map<String, dynamic> dashboard) {
    if (dashboard['trades'] is Map && dashboard['trades']['data'] is List) {
      return dashboard['trades']['data'];
    }

    return [];
  }
}
