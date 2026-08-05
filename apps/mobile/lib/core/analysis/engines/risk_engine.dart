import '../../market_data/models/candle.dart';

class RiskResult {
  final String level;
  final int score;
  final String reason;
  final double averageRangePercent;
  final double currentRangePercent;

  const RiskResult({
    required this.level,
    required this.score,
    required this.reason,
    required this.averageRangePercent,
    required this.currentRangePercent,
  });
}

class RiskEngine {
  static RiskResult analyze({required List<Candle> candles, int period = 14}) {
    if (candles.length < period + 1) {
      return const RiskResult(
        level: 'Unknown',
        score: 0,
        reason: 'Not enough candle data to evaluate market-condition risk.',
        averageRangePercent: 0,
        currentRangePercent: 0,
      );
    }

    final recent = candles.sublist(candles.length - period);

    double totalRangePercent = 0;

    for (final candle in recent) {
      if (candle.close <= 0) {
        continue;
      }

      final rangePercent = ((candle.high - candle.low) / candle.close) * 100;

      totalRangePercent += rangePercent;
    }

    final averageRangePercent = totalRangePercent / recent.length;

    final latest = candles.last;

    final currentRangePercent = latest.close > 0
        ? ((latest.high - latest.low) / latest.close) * 100
        : 0.0;

    final relativeExpansion = averageRangePercent > 0
        ? currentRangePercent / averageRangePercent
        : 0.0;

    final String level;
    final int score;
    final String reason;

    if (relativeExpansion >= 2.0) {
      level = 'High';
      score = 35;
      reason =
          'Current candle range is ${relativeExpansion.toStringAsFixed(2)}x the recent average, indicating elevated market risk.';
    } else if (relativeExpansion >= 1.5) {
      level = 'Elevated';
      score = 55;
      reason =
          'Current candle range is ${relativeExpansion.toStringAsFixed(2)}x the recent average, indicating increased market risk.';
    } else if (relativeExpansion >= 0.75) {
      level = 'Normal';
      score = 80;
      reason =
          'Current price range is consistent with recent market volatility.';
    } else {
      level = 'Low';
      score = 85;
      reason = 'Current price range is below the recent volatility average.';
    }

    return RiskResult(
      level: level,
      score: score,
      reason: reason,
      averageRangePercent: averageRangePercent,
      currentRangePercent: currentRangePercent,
    );
  }
}
