class RiskRules {
  final double riskRewardRatio;
  final double riskPercent;

  const RiskRules({required this.riskRewardRatio, required this.riskPercent});

  int calculateScore() {
    int score = 0;

    if (riskRewardRatio >= 2.0) {
      score += 10;
    }

    if (riskPercent <= 2.0) {
      score += 10;
    }

    return score;
  }

  List<String> reasons() {
    final List<String> list = [];

    if (riskRewardRatio >= 2.0) {
      list.add("Risk : Reward is acceptable");
    } else {
      list.add("Risk : Reward is too low");
    }

    if (riskPercent <= 2.0) {
      list.add("Risk per trade is within limit");
    } else {
      list.add("Risk per trade is too high");
    }

    return list;
  }
}
