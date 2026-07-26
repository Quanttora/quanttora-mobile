class TradeAnalysisResult {
  final double confidence;

  final bool trendPassed;
  final bool emaPassed;
  final bool vwapPassed;
  final bool volumePassed;
  final bool riskRewardPassed;

  final String verdict;
  final String summary;

  const TradeAnalysisResult({
    required this.confidence,
    required this.trendPassed,
    required this.emaPassed,
    required this.vwapPassed,
    required this.volumePassed,
    required this.riskRewardPassed,
    required this.verdict,
    required this.summary,
  });
}

class TradeAnalysisService {
  const TradeAnalysisService();

  TradeAnalysisResult analyze({
    required bool trend,
    required bool ema,
    required bool vwap,
    required bool volume,
    required bool riskReward,
  }) {
    int score = 0;

    if (trend) score += 20;
    if (ema) score += 20;
    if (vwap) score += 20;
    if (volume) score += 20;
    if (riskReward) score += 20;

    String verdict;
    String summary;

    if (score >= 80) {
      verdict = "EXECUTE";
      summary =
          "All major conditions are aligned. Trade quality is excellent.";
    } else if (score >= 60) {
      verdict = "WAIT";
      summary =
          "Most conditions are satisfied. Wait for stronger confirmation.";
    } else {
      verdict = "AVOID";
      summary =
          "Multiple conditions failed. Avoid entering this trade.";
    }

    return TradeAnalysisResult(
      confidence: score.toDouble(),
      trendPassed: trend,
      emaPassed: ema,
      vwapPassed: vwap,
      volumePassed: volume,
      riskRewardPassed: riskReward,
      verdict: verdict,
      summary: summary,
    );
  }
}