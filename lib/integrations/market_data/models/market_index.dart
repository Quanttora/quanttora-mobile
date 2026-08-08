class MarketIndex {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double percentChange;
  final DateTime lastUpdated;

  const MarketIndex({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.percentChange,
    required this.lastUpdated,
  });

  factory MarketIndex.fromJson(
    Map<String, dynamic> json, {
    required String displayName,
  }) {
    return MarketIndex(
      symbol: json['symbol']?.toString() ?? '',
      name: displayName,
      price: double.tryParse(json['close']?.toString() ?? '0') ?? 0,
      change: double.tryParse(json['change']?.toString() ?? '0') ?? 0,
      percentChange:
          double.tryParse(json['percent_change']?.toString() ?? '0') ?? 0,
      lastUpdated:
          DateTime.tryParse(json['datetime']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  bool get isPositive => change >= 0;
}
