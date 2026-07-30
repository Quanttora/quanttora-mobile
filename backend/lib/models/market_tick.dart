class MarketTick {
  final String instrumentKey;
  final String symbol;
  final double ltp;
  final double change;
  final DateTime timestamp;

  const MarketTick({
    required this.instrumentKey,
    required this.symbol,
    required this.ltp,
    required this.change,
    required this.timestamp,
  });

  MarketTick copyWith({
    String? instrumentKey,
    String? symbol,
    double? ltp,
    double? change,
    DateTime? timestamp,
  }) {
    return MarketTick(
      instrumentKey: instrumentKey ?? this.instrumentKey,
      symbol: symbol ?? this.symbol,
      ltp: ltp ?? this.ltp,
      change: change ?? this.change,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instrumentKey': instrumentKey,
      'symbol': symbol,
      'ltp': ltp,
      'change': change,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return '$symbol : $ltp';
  }
}