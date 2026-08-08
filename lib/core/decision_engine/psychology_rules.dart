class PsychologyRules {
  final int tradesToday;
  final bool revengeTrading;
  final bool dailyLossLimitHit;

  const PsychologyRules({
    required this.tradesToday,
    required this.revengeTrading,
    required this.dailyLossLimitHit,
  });

  int calculateScore() {
    int score = 0;

    if (tradesToday < 3) {
      score += 5;
    }

    if (!revengeTrading) {
      score += 5;
    }

    if (!dailyLossLimitHit) {
      score += 5;
    }

    return score;
  }

  List<String> reasons() {
    final List<String> list = [];

    if (tradesToday < 3) {
      list.add("Trade limit not reached");
    } else {
      list.add("Maximum trades reached");
    }

    if (!revengeTrading) {
      list.add("No revenge trading detected");
    } else {
      list.add("Revenge trading detected");
    }

    if (!dailyLossLimitHit) {
      list.add("Daily loss limit not hit");
    } else {
      list.add("Daily loss limit exceeded");
    }

    return list;
  }
}
