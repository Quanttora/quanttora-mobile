class MarketTick {
  final String instrumentKey;
  final String symbol;

  final double ltp;
  final double previousClose;
  final double change;
  final double changePercent;

  final double bidPrice;
  final double askPrice;

  final int bidQuantity;
  final int askQuantity;

  final DateTime timestamp;

  const MarketTick({
    required this.instrumentKey,
    required this.symbol,
    required this.ltp,
    required this.previousClose,
    required this.change,
    required this.changePercent,
    required this.bidPrice,
    required this.askPrice,
    required this.bidQuantity,
    required this.askQuantity,
    required this.timestamp,
  });

  MarketTick copyWith({
    String? instrumentKey,
    String? symbol,
    double? ltp,
    double? previousClose,
    double? change,
    double? changePercent,
    double? bidPrice,
    double? askPrice,
    int? bidQuantity,
    int? askQuantity,
    DateTime? timestamp,
  }) {
    return MarketTick(
      instrumentKey:
          instrumentKey ?? this.instrumentKey,
      symbol: symbol ?? this.symbol,
      ltp: ltp ?? this.ltp,
      previousClose:
          previousClose ?? this.previousClose,
      change: change ?? this.change,
      changePercent:
          changePercent ?? this.changePercent,
      bidPrice: bidPrice ?? this.bidPrice,
      askPrice: askPrice ?? this.askPrice,
      bidQuantity:
          bidQuantity ?? this.bidQuantity,
      askQuantity:
          askQuantity ?? this.askQuantity,
      timestamp:
          timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instrumentKey': instrumentKey,
      'symbol': symbol,
      'ltp': ltp,
      'previousClose': previousClose,
      'change': change,
      'changePercent': changePercent,
      'bidPrice': bidPrice,
      'askPrice': askPrice,
      'bidQuantity': bidQuantity,
      'askQuantity': askQuantity,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return '$symbol : $ltp '
        '| Change: $change '
        '($changePercent%) '
        '| Bid: $bidPrice ($bidQuantity) '
        '| Ask: $askPrice ($askQuantity)';
  }
}