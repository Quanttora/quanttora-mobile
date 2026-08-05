abstract class MarketProvider {
  /// Fetch all market data required by Quanttora
  Future<Map<String, dynamic>> fetchMarketData();
}
