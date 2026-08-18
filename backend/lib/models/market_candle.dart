class MarketCandle {
  final String instrumentKey;
  final DateTime timestamp;

  final double open;
  final double high;
  final double low;
  final double close;

  final int volume;

  const MarketCandle({
    required this.instrumentKey,
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  double get typicalPrice => (high + low + close) / 3;

  Map<String, dynamic> toJson() {
    return {
      'instrumentKey': instrumentKey,
      'timestamp': timestamp.toIso8601String(),
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
      'typicalPrice': typicalPrice,
    };
  }
}
