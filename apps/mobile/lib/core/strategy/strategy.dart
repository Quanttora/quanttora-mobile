import '../indicators/indicator.dart';

class Strategy {
  final String id;
  final String name;
  final String market;
  final String tradingMode;

  final List<Indicator> indicators;

  const Strategy({
    required this.id,
    required this.name,
    required this.market,
    required this.tradingMode,
    required this.indicators,
  });
}
