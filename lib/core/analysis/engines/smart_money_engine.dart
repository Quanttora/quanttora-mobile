import '../../market_data/models/candle.dart';

class SmartMoneyResult {
  final String structure;
  final String trend;

  final bool bullish;
  final bool bearish;

  final int score;

  final String reason;

  const SmartMoneyResult({
    required this.structure,
    required this.trend,
    required this.bullish,
    required this.bearish,
    required this.score,
    required this.reason,
  });
}

class SmartMoneyEngine {
  static SmartMoneyResult analyze({
    required List<Candle> candles,
  }) {
    if (candles.length < 6) {
      return const SmartMoneyResult(
        structure: 'Unavailable',
        trend: 'Unknown',
        bullish: false,
        bearish: false,
        score: 0,
        reason: 'Not enough candles to analyze market structure.',
      );
    }

    final c1 = candles[candles.length - 6];
    final c2 = candles[candles.length - 5];
    final c3 = candles[candles.length - 4];
    final c4 = candles[candles.length - 3];
    final c5 = candles[candles.length - 2];
    final c6 = candles.last;

    // Higher High + Higher Low
    final bullishStructure =
        c2.high > c1.high &&
        c3.high > c2.high &&
        c4.high > c3.high &&
        c5.low > c4.low &&
        c6.low > c5.low;

    // Lower High + Lower Low
    final bearishStructure =
        c2.low < c1.low &&
        c3.low < c2.low &&
        c4.low < c3.low &&
        c5.high < c4.high &&
        c6.high < c5.high;

    if (bullishStructure) {
      return const SmartMoneyResult(
        structure: 'Bullish BOS',
        trend: 'Bullish',
        bullish: true,
        bearish: false,
        score: 95,
        reason:
            'Higher highs and higher lows indicate institutional bullish market structure.',
      );
    }

    if (bearishStructure) {
      return const SmartMoneyResult(
        structure: 'Bearish BOS',
        trend: 'Bearish',
        bullish: false,
        bearish: true,
        score: 95,
        reason:
            'Lower highs and lower lows indicate institutional bearish market structure.',
      );
    }

    return const SmartMoneyResult(
      structure: 'Range',
      trend: 'Neutral',
      bullish: false,
      bearish: false,
      score: 55,
      reason:
          'No clear institutional market structure detected.',
    );
  }
}