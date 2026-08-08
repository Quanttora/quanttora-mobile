enum NewsDataStatus { available, unavailable }

class NewsResult {
  final bool highImpactNews;
  final NewsDataStatus dataStatus;
  final int score;
  final String reason;

  const NewsResult({
    required this.highImpactNews,
    required this.dataStatus,
    required this.score,
    required this.reason,
  });

  bool get dataAvailable => dataStatus == NewsDataStatus.available;

  bool get safeToTrade => dataAvailable && !highImpactNews;
}

class NewsEngine {
  const NewsEngine._();

  static NewsResult analyze({
    required bool dataAvailable,
    bool highImpactNews = false,
  }) {
    if (!dataAvailable) {
      return const NewsResult(
        highImpactNews: false,
        dataStatus: NewsDataStatus.unavailable,
        score: 0,
        reason: 'Reliable news-safety data is unavailable.',
      );
    }

    if (highImpactNews) {
      return const NewsResult(
        highImpactNews: true,
        dataStatus: NewsDataStatus.available,
        score: 40,
        reason: 'High-impact market-moving news risk detected.',
      );
    }

    return const NewsResult(
      highImpactNews: false,
      dataStatus: NewsDataStatus.available,
      score: 95,
      reason: 'No high-impact market-moving news risk detected.',
    );
  }
}
