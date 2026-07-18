import 'indicator.dart';

class EmaIndicator implements Indicator {
  final bool priceAboveEma22;
  final bool ema22AboveEma33;
  final bool emaSlopeUp;

  const EmaIndicator({
    required this.priceAboveEma22,
    required this.ema22AboveEma33,
    required this.emaSlopeUp,
  });

  @override
  String get name => "EMA";

  @override
  String get category => "Trend";

  @override
  int get maxScore => 15;

  @override
  bool get passed =>
      priceAboveEma22 &&
      ema22AboveEma33 &&
      emaSlopeUp;

  @override
  int calculate() {
    int score = 0;

    if (priceAboveEma22) score += 5;
    if (ema22AboveEma33) score += 5;
    if (emaSlopeUp) score += 5;

    return score;
  }

  @override
  List<String> get reasons {
    final List<String> list = [];

    if (priceAboveEma22) {
      list.add("Price is above EMA 22");
    } else {
      list.add("Price is below EMA 22");
    }

    if (ema22AboveEma33) {
      list.add("EMA 22 is above EMA 33");
    } else {
      list.add("EMA 22 is below EMA 33");
    }

    if (emaSlopeUp) {
      list.add("EMA trend is rising");
    } else {
      list.add("EMA trend is falling");
    }

    return list;
  }
}