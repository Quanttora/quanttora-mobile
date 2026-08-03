import '../../market_data/models/candle.dart';

class TrendResult {
  final String trend;
  final int score;
  final String reason;

  const TrendResult({
    required this.trend,
    required this.score,
    required this.reason,
  });
}

class TrendEngine {
  static TrendResult analyze({
    required List<Candle> candles,
    required String direction,
    int lookback = 20,
  }) {
    if (candles.length < 5) {
      return const TrendResult(
        trend: 'Unknown',
        score: 0,
        reason: 'Not enough candles to determine market structure.',
      );
    }

    final count =
        candles.length < lookback ? candles.length : lookback;

    final recent =
        candles.sublist(candles.length - count);

    int bullishStructure = 0;
    int bearishStructure = 0;

    for (int i = 1; i < recent.length; i++) {
      final previous = recent[i - 1];
      final current = recent[i];

      final higherHigh =
          current.high > previous.high;

      final higherLow =
          current.low > previous.low;

      final lowerHigh =
          current.high < previous.high;

      final lowerLow =
          current.low < previous.low;

      if (higherHigh && higherLow) {
        bullishStructure++;
      }

      if (lowerHigh && lowerLow) {
        bearishStructure++;
      }
    }

    final totalComparisons = recent.length - 1;

    final bullishRatio =
        bullishStructure / totalComparisons;

    final bearishRatio =
        bearishStructure / totalComparisons;

    String trend;
    int baseScore;
    String structureReason;

    if (bullishRatio > bearishRatio &&
        bullishRatio >= 0.40) {
      trend = 'Bullish';
      baseScore = 90;
      structureReason =
          'Recent candles show a dominant higher-high and higher-low structure.';
    } else if (bearishRatio > bullishRatio &&
        bearishRatio >= 0.40) {
      trend = 'Bearish';
      baseScore = 90;
      structureReason =
          'Recent candles show a dominant lower-high and lower-low structure.';
    } else {
      trend = 'Sideways';
      baseScore = 45;
      structureReason =
          'Recent price structure is mixed without a clear directional trend.';
    }

    final normalizedDirection =
        direction.trim().toUpperCase();

    final directionMatches =
        (normalizedDirection == 'CALL' &&
                trend == 'Bullish') ||
            (normalizedDirection == 'PUT' &&
                trend == 'Bearish');

    final score = trend == 'Sideways'
        ? baseScore
        : directionMatches
            ? baseScore
            : 35;

    final reason = trend == 'Sideways'
        ? structureReason
        : directionMatches
            ? '$structureReason This supports the $normalizedDirection direction.'
            : '$structureReason This does not support the $normalizedDirection direction.';

    return TrendResult(
      trend: trend,
      score: score,
      reason: reason,
    );
  }
}