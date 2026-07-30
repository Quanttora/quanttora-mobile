import 'package:backend/models/market_tick.dart';

class MarketStore {
  MarketStore._();

  static final MarketStore instance = MarketStore._();

  final Map<String, MarketTick> _ticks = {};

  void update(MarketTick tick) {
    _ticks[tick.instrumentKey] = tick;
  }

  MarketTick? get(String instrumentKey) {
    return _ticks[instrumentKey];
  }

  List<MarketTick> getAll() {
    return _ticks.values.toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'market': _ticks.values
          .map((tick) => tick.toJson())
          .toList(),
    };
  }

  void clear() {
    _ticks.clear();
  }
}