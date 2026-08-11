abstract class BrokerOptionChainInterface {
  Future<Map<String, dynamic>> getOptionChain({
    required String instrumentKey,
    String expiryDate = 'current_week',
  });
}
