import 'package:backend/models/market_candle.dart';

class TechnicalIndicatorService {
  TechnicalIndicatorService._();

  static final TechnicalIndicatorService instance =
      TechnicalIndicatorService._();

  /// Calculates EMA for the supplied candles.
  ///
  /// Candles must be ordered oldest -> newest.
  List<double?> ema(List<MarketCandle> candles, int period) {
    if (period <= 0) {
      throw ArgumentError('EMA period must be greater than zero.');
    }

    final result = List<double?>.filled(candles.length, null);

    if (candles.length < period) {
      return result;
    }

    double sum = 0;

    for (var i = 0; i < period; i++) {
      sum += candles[i].close;
    }

    double previousEma = sum / period;

    result[period - 1] = previousEma;

    final multiplier = 2 / (period + 1);

    for (var i = period; i < candles.length; i++) {
      final currentClose = candles[i].close;

      previousEma = ((currentClose - previousEma) * multiplier) + previousEma;

      result[i] = previousEma;
    }

    return result;
  }

  /// Calculates a single latest EMA value.
  double? latestEma(List<MarketCandle> candles, int period) {
    final values = ema(candles, period);

    for (var i = values.length - 1; i >= 0; i--) {
      if (values[i] != null) {
        return values[i];
      }
    }

    return null;
  }

  /// Calculates True Range for every candle.
  List<double> trueRange(List<MarketCandle> candles) {
    if (candles.isEmpty) {
      return [];
    }

    final result = <double>[];

    for (var i = 0; i < candles.length; i++) {
      final candle = candles[i];

      if (i == 0) {
        result.add(candle.high - candle.low);
        continue;
      }

      final previousClose = candles[i - 1].close;

      final highLow = candle.high - candle.low;

      final highPreviousClose = (candle.high - previousClose).abs();

      final lowPreviousClose = (candle.low - previousClose).abs();

      result.add(_max3(highLow, highPreviousClose, lowPreviousClose));
    }

    return result;
  }

  /// Calculates Wilder's ATR.
  List<double?> atr(List<MarketCandle> candles, int period) {
    if (period <= 0) {
      throw ArgumentError('ATR period must be greater than zero.');
    }

    final result = List<double?>.filled(candles.length, null);

    if (candles.length < period) {
      return result;
    }

    final tr = trueRange(candles);

    double initialSum = 0;

    for (var i = 0; i < period; i++) {
      initialSum += tr[i];
    }

    double previousAtr = initialSum / period;

    result[period - 1] = previousAtr;

    for (var i = period; i < candles.length; i++) {
      previousAtr = ((previousAtr * (period - 1)) + tr[i]) / period;

      result[i] = previousAtr;
    }

    return result;
  }

  /// Calculates Wilder ADX.
  ///
  /// The returned value is null until enough candles
  /// are available for the requested period.
  List<double?> adx(List<MarketCandle> candles, int period) {
    if (period <= 0) {
      throw ArgumentError('ADX period must be greater than zero.');
    }

    final result = List<double?>.filled(candles.length, null);

    if (candles.length < (period * 2)) {
      return result;
    }

    final tr = List<double>.filled(candles.length, 0);

    final plusDm = List<double>.filled(candles.length, 0);

    final minusDm = List<double>.filled(candles.length, 0);

    for (var i = 1; i < candles.length; i++) {
      final current = candles[i];
      final previous = candles[i - 1];

      final highDifference = current.high - previous.high;

      final lowDifference = previous.low - current.low;

      plusDm[i] = highDifference > lowDifference && highDifference > 0
          ? highDifference
          : 0;

      minusDm[i] = lowDifference > highDifference && lowDifference > 0
          ? lowDifference
          : 0;

      final highLow = current.high - current.low;

      final highPreviousClose = (current.high - previous.close).abs();

      final lowPreviousClose = (current.low - previous.close).abs();

      tr[i] = _max3(highLow, highPreviousClose, lowPreviousClose);
    }

    double trSum = 0;
    double plusDmSum = 0;
    double minusDmSum = 0;

    for (var i = 1; i <= period; i++) {
      trSum += tr[i];
      plusDmSum += plusDm[i];
      minusDmSum += minusDm[i];
    }

    final dx = List<double?>.filled(candles.length, null);

    double smoothedTr = trSum;
    double smoothedPlusDm = plusDmSum;
    double smoothedMinusDm = minusDmSum;

    for (var i = period; i < candles.length; i++) {
      if (i > period) {
        smoothedTr = smoothedTr - (smoothedTr / period) + tr[i];

        smoothedPlusDm = smoothedPlusDm - (smoothedPlusDm / period) + plusDm[i];

        smoothedMinusDm =
            smoothedMinusDm - (smoothedMinusDm / period) + minusDm[i];
      }

      if (smoothedTr <= 0) {
        continue;
      }

      final plusDi = 100 * (smoothedPlusDm / smoothedTr);

      final minusDi = 100 * (smoothedMinusDm / smoothedTr);

      final denominator = plusDi + minusDi;

      if (denominator <= 0) {
        dx[i] = 0;
      } else {
        dx[i] = 100 * ((plusDi - minusDi).abs() / denominator);
      }
    }

    final firstAdxIndex = period * 2 - 1;

    if (firstAdxIndex >= candles.length) {
      return result;
    }

    double dxSum = 0;
    var validDxCount = 0;

    for (var i = period; i <= firstAdxIndex; i++) {
      final value = dx[i];

      if (value != null) {
        dxSum += value;
        validDxCount++;
      }
    }

    if (validDxCount == 0) {
      return result;
    }

    double previousAdx = dxSum / validDxCount;

    result[firstAdxIndex] = previousAdx;

    for (var i = firstAdxIndex + 1; i < candles.length; i++) {
      final value = dx[i];

      if (value == null) {
        continue;
      }

      previousAdx = ((previousAdx * (period - 1)) + value) / period;

      result[i] = previousAdx;
    }

    return result;
  }

  /// Returns the latest ADX value.
  double? latestAdx(List<MarketCandle> candles, int period) {
    final values = adx(candles, period);

    for (var i = values.length - 1; i >= 0; i--) {
      if (values[i] != null) {
        return values[i];
      }
    }

    return null;
  }

  static double _max3(double a, double b, double c) {
    var result = a;

    if (b > result) {
      result = b;
    }

    if (c > result) {
      result = c;
    }

    return result;
  }
}
