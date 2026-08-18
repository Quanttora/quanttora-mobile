import 'package:backend/models/market_tick.dart';

class MarketStore {
  MarketStore._();

  static final MarketStore instance = MarketStore._();

  final Map<String, MarketTick> _ticks = {};

  // Cumulative price-volume state per instrument.
  final Map<String, double> _cumulativePriceVolume = {};

  // Last cumulative traded volume received from the broker.
  final Map<String, int> _previousVolume = {};

  void update(MarketTick tick) {
    final previousVolume = _previousVolume[tick.instrumentKey] ?? 0;

    final currentVolume = tick.volume;

    // Upstox volume is cumulative during the trading session.
    //
    // If the broker volume increases, only the new volume
    // contributes to the live VWAP calculation.
    if (currentVolume > previousVolume && tick.ltp > 0) {
      final volumeDelta = currentVolume - previousVolume;

      final previousPriceVolume =
          _cumulativePriceVolume[tick.instrumentKey] ?? 0.0;

      _cumulativePriceVolume[tick.instrumentKey] =
          previousPriceVolume + (tick.ltp * volumeDelta);
    }

    // Detect a broker/session volume reset.
    if (currentVolume < previousVolume) {
      _cumulativePriceVolume.remove(tick.instrumentKey);
    }

    _previousVolume[tick.instrumentKey] = currentVolume;

    final cumulativePriceVolume =
        _cumulativePriceVolume[tick.instrumentKey] ?? 0.0;

    final vwap = currentVolume > 0
        ? cumulativePriceVolume / currentVolume
        : 0.0;

    _ticks[tick.instrumentKey] = tick.copyWith(vwap: vwap);
  }

  MarketTick? get(String instrumentKey) {
    return _ticks[instrumentKey];
  }

  List<MarketTick> getAll() {
    return _ticks.values.toList();
  }

  Map<String, dynamic> toJson() {
    return {'market': _ticks.values.map((tick) => tick.toJson()).toList()};
  }

  void clear() {
    _ticks.clear();
    _cumulativePriceVolume.clear();
    _previousVolume.clear();
  }

  void resetVwap(String instrumentKey) {
    _cumulativePriceVolume.remove(instrumentKey);

    _previousVolume.remove(instrumentKey);
  }
}
