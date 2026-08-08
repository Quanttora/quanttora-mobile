import '../strategy/strategy.dart';
import 'q_score.dart';

class ScoreEngine {
  const ScoreEngine();

  QScore calculate(Strategy strategy) {
    int totalScore = 0;
    int maxScore = 0;

    final List<String> reasons = [];

    for (final indicator in strategy.indicators) {
      final score = indicator.calculate();

      totalScore += score;
      maxScore += indicator.maxScore;

      reasons.addAll(indicator.reasons);
    }

    final double percentage = maxScore == 0 ? 0 : (totalScore / maxScore) * 100;

    return QScore(
      score: totalScore,
      maxScore: maxScore,
      percentage: percentage,
      reasons: reasons,
    );
  }

  String getMarketReadiness(QScore score) {
    if (score.percentage >= 90) {
      return "Excellent";
    }

    if (score.percentage >= 80) {
      return "Strong";
    }

    if (score.percentage >= 70) {
      return "Healthy";
    }

    if (score.percentage >= 60) {
      return "Weak";
    }

    return "Poor";
  }

  String getCapitalProtection(QScore score) {
    if (score.percentage >= 90) {
      return "Excellent";
    }

    if (score.percentage >= 75) {
      return "Good";
    }

    if (score.percentage >= 60) {
      return "Moderate";
    }

    return "High Risk";
  }

  double getProbability(QScore score) {
    return score.percentage;
  }

  bool isStrategyAligned(QScore score) {
    return score.percentage >= 75;
  }
}
