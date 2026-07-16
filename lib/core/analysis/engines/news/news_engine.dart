class NewsResult {
  final bool highImpactNews;
  final int score;
  final String reason;

  const NewsResult({
    required this.highImpactNews,
    required this.score,
    required this.reason,
  });
}

class NewsEngine {
  static NewsResult analyze({
    required bool highImpactNews,
  }) {
    return NewsResult(
      highImpactNews: highImpactNews,
      score: highImpactNews ? 40 : 95,
      reason: highImpactNews
          ? "High-impact news detected."
          : "No major news risk detected.",
    );
  }
}