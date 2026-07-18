class BrokerPosition {
  final String symbol;

  final int quantity;

  final double averagePrice;

  final double ltp;

  final double pnl;

  const BrokerPosition({
    required this.symbol,
    required this.quantity,
    required this.averagePrice,
    required this.ltp,
    required this.pnl,
  });
}