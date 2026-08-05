import '../../market_data/models/candle.dart';

class RSIResult {
  final double value;
  final int score;
  final String status;
  final String reason;

  const RSIResult({
    required this.value,
    required this.score,
    required this.status,
    required this.reason,
  });
}

class RSIEngine {
  static RSIResult analyze({
    required List<Candle> candles,
    required String direction,
  }) {
    if (candles.length < 15) {
      return const RSIResult(
        value: 0,
        score: 0,
        status: 'Insufficient Data',
        reason: 'Not enough candle data to calculate RSI.',
      );
    }

    const period = 14;

    double gains = 0;
    double losses = 0;

    final start = candles.length - period;

    for (int i = start; i < candles.length; i++) {
      final change = candles[i].close - candles[i - 1].close;

      if (change > 0) {
        gains += change;
      } else if (change < 0) {
        losses += change.abs();
      }
    }

    final averageGain = gains / period;
    final averageLoss = losses / period;

    double rsi;

    if (averageLoss == 0) {
      rsi = 100;
    } else {
      final rs = averageGain / averageLoss;
      rsi = 100 - (100 / (1 + rs));
    }

    final isCall = direction.toUpperCase() == 'CALL';

    int score;
    String status;
    String reason;

    if (isCall) {
      if (rsi >= 50 && rsi <= 70) {
        score = 90;
        status = 'Bullish Momentum';
        reason = 'RSI ${rsi.toStringAsFixed(1)} supports the CALL direction.';
      } else if (rsi > 70) {
        score = 60;
        status = 'Overbought';
        reason =
            'RSI ${rsi.toStringAsFixed(1)} indicates overbought conditions.';
      } else {
        score = 40;
        status = 'Weak Momentum';
        reason =
            'RSI ${rsi.toStringAsFixed(1)} does not support the CALL direction.';
      }
    } else {
      if (rsi >= 30 && rsi < 50) {
        score = 90;
        status = 'Bearish Momentum';
        reason = 'RSI ${rsi.toStringAsFixed(1)} supports the PUT direction.';
      } else if (rsi < 30) {
        score = 60;
        status = 'Oversold';
        reason = 'RSI ${rsi.toStringAsFixed(1)} indicates oversold conditions.';
      } else {
        score = 40;
        status = 'Weak Bearish Momentum';
        reason =
            'RSI ${rsi.toStringAsFixed(1)} does not support the PUT direction.';
      }
    }

    return RSIResult(value: rsi, score: score, status: status, reason: reason);
  }
}
