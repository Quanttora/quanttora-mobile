import 'package:backend/models/market_candle.dart';

class CandleAggregationService {
  CandleAggregationService._();

  static final CandleAggregationService instance = CandleAggregationService._();

  List<MarketCandle> aggregate(
    List<MarketCandle> candles, {
    required int minutes,
  }) {
    if (minutes <= 0) {
      throw ArgumentError('Aggregation minutes must be greater than zero.');
    }

    if (candles.isEmpty) {
      return [];
    }

    final sorted = List<MarketCandle>.from(candles)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final result = <MarketCandle>[];

    MarketCandle? current;

    DateTime? bucketStart;

    var bucketVolume = 0;

    for (final candle in sorted) {
      final start = _bucketStart(candle.timestamp, minutes);

      if (bucketStart == null || start != bucketStart) {
        if (current != null) {
          result.add(current);
        }

        bucketStart = start;

        current = MarketCandle(
          instrumentKey: candle.instrumentKey,
          timestamp: start,
          open: candle.open,
          high: candle.high,
          low: candle.low,
          close: candle.close,
          volume: candle.volume,
        );

        bucketVolume = candle.volume;

        continue;
      }

      final previous = current!;

      bucketVolume += candle.volume;

      current = MarketCandle(
        instrumentKey: previous.instrumentKey,
        timestamp: previous.timestamp,
        open: previous.open,
        high: previous.high > candle.high ? previous.high : candle.high,
        low: previous.low < candle.low ? previous.low : candle.low,
        close: candle.close,
        volume: bucketVolume,
      );
    }

    if (current != null) {
      result.add(current);
    }

    return result;
  }

  static DateTime _bucketStart(DateTime timestamp, int minutes) {
    final local = timestamp.toLocal();

    final totalMinutes = (local.hour * 60) + local.minute;

    final bucketMinutes = (totalMinutes ~/ minutes) * minutes;

    return DateTime(
      local.year,
      local.month,
      local.day,
      bucketMinutes ~/ 60,
      bucketMinutes % 60,
    );
  }
}
