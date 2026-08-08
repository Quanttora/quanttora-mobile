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
  static MarketHealthResult analyze({
    required int trendScore,
    required int emaScore,
    required int adxScore,
    required int rsiScore,
    required int riskScore,
  }) {
    final scores = <int>[trendScore, emaScore, adxScore, rsiScore, riskScore];

    final score = scores.reduce((a, b) => a + b) ~/ scores.length;

    final String status;
    final String reason;

    if (score >= 80) {
      status = 'Healthy';
      reason =
          'Trend, momentum, strength and market risk conditions are broadly supportive.';
    } else if (score >= 65) {
      status = 'Moderate';
      reason = 'Market conditions are mixed but remain reasonably supportive.';
    } else if (score >= 50) {
      status = 'Cautious';
      reason = 'Several market conditions are weak or conflicting.';
    } else {
      status = 'Weak';
      reason = 'Current trend, momentum or risk conditions are not supportive.';
    }

    return MarketHealthResult(score: score, status: status, reason: reason);
  }
}
