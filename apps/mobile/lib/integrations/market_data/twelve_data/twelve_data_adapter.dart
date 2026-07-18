import '../core/market_provider.dart';

class TwelveDataAdapter implements MarketProvider {
  @override
  Future<Map<String, dynamic>> fetchMarketData() async {
    // Live API integration will be implemented in the next step.
    return {};
  }
}