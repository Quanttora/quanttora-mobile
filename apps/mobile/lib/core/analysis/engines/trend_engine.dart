class TrendResult {
  final String trend;
  final int score;
  final String reason;

  const TrendResult({
    required this.trend,
    required this.score,
    required this.reason,
  });
}

class TrendEngine {
  static TrendResult analyze({
    required String market,
    required String direction,
  }) {

    // Temporary logic
    // Later this will use:
    // EMA 22
    // EMA 33
    // Higher Timeframe
    // Swing Structure

    if (direction == "CALL") {
      return const TrendResult(
        trend: "Bullish",
        score: 91,
        reason: "Higher highs and higher lows detected.",
      );
    }

    return const TrendResult(
      trend: "Bearish",
      score: 89,
      reason: "Lower highs and lower lows detected.",
    );
  }
}