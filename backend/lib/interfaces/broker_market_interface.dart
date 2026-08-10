abstract class BrokerMarketInterface {
  Future<Map<String, dynamic>> getFunds(
    String accessToken,
  );

  Future<Map<String, dynamic>> getProfile(
    String accessToken,
  );

  Future<Map<String, dynamic>> getHoldings(
    String accessToken,
  );

  Future<Map<String, dynamic>> getPositions(
    String accessToken,
  );

  Future<Map<String, dynamic>> getOrderBook(
    String accessToken,
  );

  Future<Map<String, dynamic>> getTradeBook(
    String accessToken,
  );

  Future<Map<String, dynamic>> getQuotes(
    String accessToken,
    String instrumentKeys,
  );

  Future<Map<String, dynamic>> getHistoricalCandles(
    String accessToken,
    String instrumentKey,
    String interval,
    String toDate,
    String fromDate,
  );
}