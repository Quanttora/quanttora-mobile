import '../../market_data/models/candle.dart';

class LiquiditySweepResult {
  final bool detected;
  final bool bullish;

  final int score;

  final String status;
  final String reason;

  const LiquiditySweepResult({
    required this.detected,
    required this.bullish,
    required this.score,
    required this.status,
    required this.reason,
  });
}

class LiquiditySweepEngine {
  static LiquiditySweepResult analyze({
    required List<Candle> candles,
  }) {
    if (candles.length < 5) {
      return const LiquiditySweepResult(
        detected: false,
        bullish: false,
        score: 0,
        status: 'Insufficient Data',
        reason: 'Not enough candles to detect liquidity sweep.',
      );
    }

    final current = candles.last;
    final previous = candles[candles.length - 2];

    // Bullish Sweep
    if (current.low < previous.low &&
        current.close > previous.low &&
        current.close > current.open) {
      return const LiquiditySweepResult(
        detected: true,
        bullish: true,
        score: 92,
        status: 'Bullish Liquidity Sweep',
        reason:
            'Price swept previous low and closed back above it, indicating possible stop-loss hunting and bullish reversal.',
      );
    }

    // Bearish Sweep
    if (current.high > previous.high &&
        current.close < previous.high &&
        current.close < current.open) {
      return const LiquiditySweepResult(
        detected: true,
        bullish: false,
        score: 92,
        status: 'Bearish Liquidity Sweep',
        reason:
            'Price swept previous high and closed back below it, indicating possible liquidity grab and bearish reversal.',
      );
    }

    return const LiquiditySweepResult(
      detected: false,
      bullish: false,
      score: 55,
      status: 'No Liquidity Sweep',
      reason: 'No significant liquidity sweep detected.',
    );
  }
}