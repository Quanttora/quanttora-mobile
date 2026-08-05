class QScore {
  final int score;
  final int maxScore;
  final double percentage;

  final List<String> reasons;

  const QScore({
    required this.score,
    required this.maxScore,
    required this.percentage,
    required this.reasons,
  });

  bool get isExcellent => percentage >= 90;

  bool get isGood => percentage >= 75 && percentage < 90;

  bool get isRisky => percentage >= 60 && percentage < 75;

  bool get shouldAvoid => percentage < 60;

  String get verdict {
    if (isExcellent) {
      return "EXECUTE";
    }

    if (isGood) {
      return "GOOD SETUP";
    }

    if (isRisky) {
      return "HIGH RISK";
    }

    return "AVOID";
  }

  String get riskLevel {
    if (percentage >= 90) {
      return "LOW";
    }

    if (percentage >= 75) {
      return "MEDIUM";
    }

    if (percentage >= 60) {
      return "HIGH";
    }

    return "VERY HIGH";
  }
}
