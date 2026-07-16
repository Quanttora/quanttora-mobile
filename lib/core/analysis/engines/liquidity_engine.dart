class LiquidityResult {
  final String status;
  final int score;
  final String reason;

  const LiquidityResult({
    required this.status,
    required this.score,
    required this.reason,
  });
}

class LiquidityEngine {
  static LiquidityResult analyze() {
    return const LiquidityResult(
      status: "Excellent",
      score: 92,
      reason: "Bid-ask spread is healthy with strong participation.",
    );
  }
}