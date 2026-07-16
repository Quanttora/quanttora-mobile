class RSIResult {
  final int value;
  final int score;
  final String status;
  final String reason;

  const RSIResult({
    required this.value,
    required this.score,
    required this.status,
    required this.reason,
  });
}

class RSIEngine {
  static RSIResult analyze() {
    return const RSIResult(
      value: 61,
      score: 82,
      status: "Bullish Momentum",
      reason: "RSI is above 50 without being overbought.",
    );
  }
}