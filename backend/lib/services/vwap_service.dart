import 'package:backend/models/market_candle.dart';

class VwapService {
  VwapService._();

  static final VwapService instance = VwapService._();

  final Map<String, double> _cumulativePriceVolume = {};
  final Map<String, int> _cumulativeVolume = {};

  double calculateFromCandles(
    String instrumentKey,
    List<MarketCandle> candles,
  ) {
    double priceVolume = 0;
    int volume = 0;

    for (final candle in candles) {
      if (candle.volume <= 0) {
        continue;
      }

      priceVolume += candle.typicalPrice * candle.volume;
      volume += candle.volume;
    }

    _cumulativePriceVolume[instrumentKey] = priceVolume;
    _cumulativeVolume[instrumentKey] = volume;

    if (volume == 0) {
      return 0;
    }

    return priceVolume / volume;
  }

  double addLiveVolume(
    String instrumentKey, {
    required double price,
    required int volumeDelta,
  }) {
    if (price <= 0 || volumeDelta <= 0) {
      return currentVwap(instrumentKey);
    }

    final currentPriceVolume = _cumulativePriceVolume[instrumentKey] ?? 0;

    final currentVolume = _cumulativeVolume[instrumentKey] ?? 0;

    final newPriceVolume = currentPriceVolume + (price * volumeDelta);

    final newVolume = currentVolume + volumeDelta;

    _cumulativePriceVolume[instrumentKey] = newPriceVolume;

    _cumulativeVolume[instrumentKey] = newVolume;

    return newPriceVolume / newVolume;
  }

  double currentVwap(String instrumentKey) {
    final priceVolume = _cumulativePriceVolume[instrumentKey] ?? 0;

    final volume = _cumulativeVolume[instrumentKey] ?? 0;

    if (volume == 0) {
      return 0;
    }

    return priceVolume / volume;
  }

  int currentVolume(String instrumentKey) {
    return _cumulativeVolume[instrumentKey] ?? 0;
  }

  void reset(String instrumentKey) {
    _cumulativePriceVolume.remove(instrumentKey);
    _cumulativeVolume.remove(instrumentKey);
  }

  void resetAll() {
    _cumulativePriceVolume.clear();
    _cumulativeVolume.clear();
  }
}
