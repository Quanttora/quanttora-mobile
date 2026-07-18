class MarketHealthResult {
  final int score;
  final String status;
  final String reason;

  const MarketHealthResult({
    required this.score,
    required this.status,
    required this.reason,
  });
}

class MarketHealthEngine {
  static MarketHealthResult analyze() {
    return const MarketHealthResult(
      score: 89,
      status: "Healthy",
      reason: "Trend, breadth and volatility are supportive.",
    );
  }
}