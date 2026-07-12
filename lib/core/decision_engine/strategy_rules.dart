class StrategyRules {
  final bool breakout;
  final bool retest;
  final bool liquiditySweep;
  final bool confirmationCandle;

  const StrategyRules({
    required this.breakout,
    required this.retest,
    required this.liquiditySweep,
    required this.confirmationCandle,
  });

  int calculateScore() {
    int score = 0;

    if (breakout) score += 5;
    if (retest) score += 5;
    if (liquiditySweep) score += 5;
    if (confirmationCandle) score += 5;

    return score;
  }

  List<String> reasons() {
    final List<String> list = [];

    if (breakout) {
      list.add("Breakout confirmed");
    }

    if (retest) {
      list.add("Retest confirmed");
    }

    if (liquiditySweep) {
      list.add("Liquidity sweep detected");
    }

    if (confirmationCandle) {
      list.add("Confirmation candle formed");
    }

    return list;
  }
}