import '../../../market_data/models/candle.dart';

class EMAResult {
  final double ema22;
  final double ema33;
  final double currentPrice;

  final bool ema22Above33;
  final bool priceAbove22;
  final bool ema22Below33;
  final bool priceBelow22;

  final bool aligned;
  final int score;
  final String reason;

  const EMAResult({
    required this.ema22,
    required this.ema33,
    required this.currentPrice,
    required this.ema22Above33,
    required this.priceAbove22,
    required this.ema22Below33,
    required this.priceBelow22,
    required this.aligned,
    required this.score,
    required this.reason,
  });
}

class EMAEngine {
  static EMAResult analyze({
    required List<Candle> candles,
    required String direction,
  }) {
    if (candles.length < 33) {
      return const EMAResult(
        ema22: 0,
        ema33: 0,
        currentPrice: 0,
        ema22Above33: false,
        priceAbove22: false,
        ema22Below33: false,
        priceBelow22: false,
        aligned: false,
        score: 0,
        reason: 'Not enough candle data for EMA analysis.',
      );
    }

    final closes = candles
        .map((candle) => candle.close)
        .toList();

    final ema22 = _calculateEMA(
      closes,
      22,
    );

    final ema33 = _calculateEMA(
      closes,
      33,
    );

    final currentPrice =
        candles.last.close;

    final ema22Above33 =
        ema22 > ema33;

    final ema22Below33 =
        ema22 < ema33;

    final priceAbove22 =
        currentPrice > ema22;

    final priceBelow22 =
        currentPrice < ema22;

    final normalizedDirection =
        direction.trim().toUpperCase();

    final isCall =
        normalizedDirection == 'CALL';

    final isPut =
        normalizedDirection == 'PUT';

    final bullishAlignment =
        ema22Above33 &&
        priceAbove22;

    final bearishAlignment =
        ema22Below33 &&
        priceBelow22;

    final aligned = isCall
        ? bullishAlignment
        : isPut
            ? bearishAlignment
            : false;

    int score;
    String reason;

    if (isCall) {
      if (bullishAlignment) {
        score = 95;
        reason =
            'Bullish EMA alignment: price is above EMA 22 and EMA 22 is above EMA 33.';
      } else if (ema22Above33 ||
          priceAbove22) {
        score = 65;
        reason =
            'Partial bullish EMA alignment detected.';
      } else {
        score = 35;
        reason =
            'EMA structure does not support the CALL direction.';
      }
    } else if (isPut) {
      if (bearishAlignment) {
        score = 95;
        reason =
            'Bearish EMA alignment: price is below EMA 22 and EMA 22 is below EMA 33.';
      } else if (ema22Below33 ||
          priceBelow22) {
        score = 65;
        reason =
            'Partial bearish EMA alignment detected.';
      } else {
        score = 35;
        reason =
            'EMA structure does not support the PUT direction.';
      }
    } else {
      score = 0;
      reason =
          'Unsupported trade direction for EMA analysis.';
    }

    return EMAResult(
      ema22: ema22,
      ema33: ema33,
      currentPrice: currentPrice,
      ema22Above33: ema22Above33,
      priceAbove22: priceAbove22,
      ema22Below33: ema22Below33,
      priceBelow22: priceBelow22,
      aligned: aligned,
      score: score,
      reason: reason,
    );
  }

  static double _calculateEMA(
    List<double> values,
    int period,
  ) {
    if (values.length < period) {
      return 0;
    }

    double sum = 0;

    for (int i = 0; i < period; i++) {
      sum += values[i];
    }

    double ema = sum / period;

    final multiplier =
        2.0 / (period + 1);

    for (
      int i = period;
      i < values.length;
      i++
    ) {
      ema =
          ((values[i] - ema) *
                  multiplier) +
              ema;
    }

    return ema;
  }
}