abstract class MarketDataProvider {
  Future<void> connect();

  Future<void> disconnect();

  Future<bool> isConnected();

  Future<dynamic> getMarketSnapshot({
    required String market,
  });
}