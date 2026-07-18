class MarketIndex {
  final String symbol;
  final String name;

  final double lastPrice;
  final double change;
  final double changePercent;

  final bool isBullish;

  final DateTime updatedAt;

  const MarketIndex({
    required this.symbol,
    required this.name,
    required this.lastPrice,
    required this.change,
    required this.changePercent,
    required this.isBullish,
    required this.updatedAt,
  });
}