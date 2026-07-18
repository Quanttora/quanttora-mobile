enum DecisionVerdict {
  execute,
  wait,
  highRisk,
  avoid,
}

class DecisionResult {
  final int totalScore;

  final int marketScore;
  final int momentumScore;
  final int riskScore;
  final int strategyScore;
  final int psychologyScore;

  final DecisionVerdict verdict;

  final List<String> reasons;

  const DecisionResult({
    required this.totalScore,
    required this.marketScore,
    required this.momentumScore,
    required this.riskScore,
    required this.strategyScore,
    required this.psychologyScore,
    required this.verdict,
    required this.reasons,
  });

  String get verdictText {
    switch (verdict) {
      case DecisionVerdict.execute:
        return "EXECUTE";

      case DecisionVerdict.wait:
        return "WAIT";

      case DecisionVerdict.highRisk:
        return "HIGH RISK";

      case DecisionVerdict.avoid:
        return "AVOID";
    }
  }

  bool get canTrade =>
      verdict == DecisionVerdict.execute;
}