class RiskResult {
  final String level;
  final int score;
  final String reason;

  const RiskResult({
    required this.level,
    required this.score,
    required this.reason,
  });
}

class RiskEngine {
  static RiskResult analyze() {
    return const RiskResult(
      level: "Low",
      score: 90,
      reason: "Market conditions support controlled risk.",
    );
  }
}