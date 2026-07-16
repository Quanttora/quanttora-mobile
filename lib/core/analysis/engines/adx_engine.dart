class ADXResult {
  final int value;
  final int score;
  final String status;
  final String reason;

  const ADXResult({
    required this.value,
    required this.score,
    required this.status,
    required this.reason,
  });
}

class ADXEngine {
  static ADXResult analyze() {
    return const ADXResult(
      value: 28,
      score: 88,
      status: "Trending",
      reason: "ADX above 25 indicates a trending market.",
    );
  }
}