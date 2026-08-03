import '../../market_data/models/candle.dart';

class VolumeResult {
  final double currentVolume;
  final double averageVolume;
  final double relativeVolume;
  final String status;
  final int score;
  final String reason;

  const VolumeResult({
    required this.currentVolume,
    required this.averageVolume,
    required this.relativeVolume,
    required this.status,
    required this.score,
    required this.reason,
  });
}

class VolumeEngine {
  static VolumeResult analyze({
    required List<Candle> candles,
    int period = 20,
  }) {
    if (candles.length < period + 1) {
      return const VolumeResult(
        currentVolume: 0,
        averageVolume: 0,
        relativeVolume: 0,
        status: 'Insufficient Data',
        score: 0,
        reason: 'Not enough candles to analyze volume.',
      );
    }

    final validCandles = candles
        .where((candle) => candle.volume > 0)
        .toList();

    if (validCandles.length < period + 1) {
      return const VolumeResult(
        currentVolume: 0,
        averageVolume: 0,
        relativeVolume: 0,
        status: 'Volume Unavailable',
        score: 0,
        reason:
            'Reliable volume data is unavailable for this instrument.',
      );
    }

    final currentCandle = validCandles.last;
    final currentVolume = currentCandle.volume;

    final previousCandles = validCandles.sublist(
      validCandles.length - period - 1,
      validCandles.length - 1,
    );

    double totalVolume = 0;

    for (final candle in previousCandles) {
      totalVolume += candle.volume;
    }

    final averageVolume = totalVolume / period;

    if (averageVolume <= 0) {
      return const VolumeResult(
        currentVolume: 0,
        averageVolume: 0,
        relativeVolume: 0,
        status: 'Volume Unavailable',
        score: 0,
        reason:
            'Reliable volume data is unavailable for this instrument.',
      );
    }

    final relativeVolume =
        currentVolume / averageVolume;

    final int score;
    final String status;
    final String reason;

    if (relativeVolume >= 1.5) {
      score = 95;
      status = 'Very High';
      reason =
          'Current volume is ${relativeVolume.toStringAsFixed(2)}x the 20-period average.';
    } else if (relativeVolume >= 1.2) {
      score = 85;
      status = 'High';
      reason =
          'Current volume is ${relativeVolume.toStringAsFixed(2)}x the 20-period average.';
    } else if (relativeVolume >= 0.8) {
      score = 65;
      status = 'Normal';
      reason =
          'Current volume is ${relativeVolume.toStringAsFixed(2)}x the 20-period average.';
    } else {
      score = 40;
      status = 'Low';
      reason =
          'Current volume is only ${relativeVolume.toStringAsFixed(2)}x the 20-period average.';
    }

    return VolumeResult(
      currentVolume: currentVolume,
      averageVolume: averageVolume,
      relativeVolume: relativeVolume,
      status: status,
      score: score,
      reason: reason,
    );
  }
}