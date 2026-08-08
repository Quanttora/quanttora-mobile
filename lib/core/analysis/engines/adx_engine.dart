import '../../market_data/models/candle.dart';

class ADXResult {
  final double value;
  final int score;
  final String status;
  final String reason;

  const ADXResult({
    required this.value,
    required this.score,
    required this.status,
    required this.reason,
  });
}

class ADXEngine {
  static ADXResult analyze({required List<Candle> candles, int period = 14}) {
    if (candles.length < (period * 2) + 1) {
      return const ADXResult(
        value: 0,
        score: 0,
        status: 'Insufficient Data',
        reason: 'Not enough candles to calculate ADX.',
      );
    }

    final trueRanges = <double>[];
    final plusDMs = <double>[];
    final minusDMs = <double>[];

    for (int i = 1; i < candles.length; i++) {
      final current = candles[i];
      final previous = candles[i - 1];

      final highLow = current.high - current.low;
      final highClose = (current.high - previous.close).abs();
      final lowClose = (current.low - previous.close).abs();

      final trueRange = [
        highLow,
        highClose,
        lowClose,
      ].reduce((a, b) => a > b ? a : b);

      final upMove = current.high - previous.high;

      final downMove = previous.low - current.low;

      final plusDM = upMove > downMove && upMove > 0 ? upMove : 0.0;

      final minusDM = downMove > upMove && downMove > 0 ? downMove : 0.0;

      trueRanges.add(trueRange);
      plusDMs.add(plusDM);
      minusDMs.add(minusDM);
    }

    double smoothedTR = 0;
    double smoothedPlusDM = 0;
    double smoothedMinusDM = 0;

    for (int i = 0; i < period; i++) {
      smoothedTR += trueRanges[i];
      smoothedPlusDM += plusDMs[i];
      smoothedMinusDM += minusDMs[i];
    }

    final dxValues = <double>[];

    for (int i = period; i < trueRanges.length; i++) {
      if (i > period) {
        smoothedTR = smoothedTR - (smoothedTR / period) + trueRanges[i];

        smoothedPlusDM =
            smoothedPlusDM - (smoothedPlusDM / period) + plusDMs[i];

        smoothedMinusDM =
            smoothedMinusDM - (smoothedMinusDM / period) + minusDMs[i];
      }

      if (smoothedTR <= 0) {
        continue;
      }

      final plusDI = 100 * (smoothedPlusDM / smoothedTR);

      final minusDI = 100 * (smoothedMinusDM / smoothedTR);

      final diTotal = plusDI + minusDI;

      if (diTotal <= 0) {
        dxValues.add(0);
        continue;
      }

      final dx = 100 * ((plusDI - minusDI).abs() / diTotal);

      dxValues.add(dx);
    }

    if (dxValues.length < period) {
      return const ADXResult(
        value: 0,
        score: 0,
        status: 'Insufficient Data',
        reason: 'Not enough data to calculate ADX.',
      );
    }

    double adx = 0;

    for (int i = 0; i < period; i++) {
      adx += dxValues[i];
    }

    adx /= period;

    for (int i = period; i < dxValues.length; i++) {
      adx = ((adx * (period - 1)) + dxValues[i]) / period;
    }

    final int score;
    final String status;
    final String reason;

    if (adx >= 25) {
      score = 90;
      status = 'Trending';
      reason =
          'ADX ${adx.toStringAsFixed(1)} indicates a strong trending market.';
    } else if (adx >= 20) {
      score = 70;
      status = 'Developing Trend';
      reason = 'ADX ${adx.toStringAsFixed(1)} indicates a developing trend.';
    } else {
      score = 40;
      status = 'Weak / Sideways';
      reason =
          'ADX ${adx.toStringAsFixed(1)} indicates a weak or sideways market.';
    }

    return ADXResult(value: adx, score: score, status: status, reason: reason);
  }
}
