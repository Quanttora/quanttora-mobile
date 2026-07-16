class HeatMapResult {
  final String sentiment;
  final int score;
  final String reason;

  const HeatMapResult({
    required this.sentiment,
    required this.score,
    required this.reason,
  });
}

class HeatMapEngine {
  static HeatMapResult analyze({
    required int advancing,
    required int declining,
  }) {

    if (advancing > declining) {
      return const HeatMapResult(
        sentiment: "Positive",
        score: 90,
        reason: "Market breadth is positive.",
      );
    }

    return const HeatMapResult(
      sentiment: "Negative",
      score: 65,
      reason: "Declining stocks dominate.",
    );
  }
}