class MarketRules {
  final bool priceAboveEma22;
  final bool ema22AboveEma33;
  final bool higherHigh;
  final bool higherLow;
  final bool aboveVwap;

  const MarketRules({
    required this.priceAboveEma22,
    required this.ema22AboveEma33,
    required this.higherHigh,
    required this.higherLow,
    required this.aboveVwap,
  });

  int calculateScore() {
    int score = 0;

    if (priceAboveEma22) score += 5;
    if (ema22AboveEma33) score += 5;
    if (higherHigh) score += 5;
    if (higherLow) score += 5;
    if (aboveVwap) score += 5;

    return score;
  }

  List<String> reasons() {
    final List<String> list = [];

    if (priceAboveEma22) {
      list.add("Price is above EMA 22");
    }

    if (ema22AboveEma33) {
      list.add("EMA 22 is above EMA 33");
    }

    if (higherHigh) {
      list.add("Higher High confirmed");
    }

    if (higherLow) {
      list.add("Higher Low confirmed");
    }

    if (aboveVwap) {
      list.add("Price is above VWAP");
    }

    return list;
  }
}