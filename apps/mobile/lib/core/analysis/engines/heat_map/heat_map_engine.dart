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
    final total = advancing + declining;

    if (total == 0) {
      return const HeatMapResult(
        sentiment: 'Unavailable',
        score: 0,
        reason: 'Real sector breadth data is unavailable.',
      );
    }

    final bullishPercentage =
        (advancing / total) * 100;

    final bearishPercentage =
        (declining / total) * 100;

    if (advancing > declining) {
      return HeatMapResult(
        sentiment: 'Positive',
        score: bullishPercentage.round(),
        reason:
            '$advancing of $total tracked sectors are advancing.',
      );
    }

    if (declining > advancing) {
      return HeatMapResult(
        sentiment: 'Negative',
        score: bearishPercentage.round(),
        reason:
            '$declining of $total tracked sectors are declining.',
      );
    }

    return HeatMapResult(
      sentiment: 'Neutral',
      score: 50,
      reason:
          'Sector breadth is evenly split: '
          '$advancing advancing and '
          '$declining declining.',
    );
  }
}