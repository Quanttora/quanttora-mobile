import '../indicators/indicator.dart';

class IndicatorRegistry {
  IndicatorRegistry._();

  static final IndicatorRegistry instance = IndicatorRegistry._();

  final Map<String, Indicator> _indicators = {};

  void register(Indicator indicator) {
    _indicators[indicator.name] = indicator;
  }

  Indicator? get(String name) {
    return _indicators[name];
  }

  List<Indicator> getAll() {
    return _indicators.values.toList();
  }

  bool contains(String name) {
    return _indicators.containsKey(name);
  }

  void clear() {
    _indicators.clear();
  }
}
