import '../indicators/indicator.dart';
import '../scoring/q_score.dart';
import 'strategy.dart';

class StrategyEngine {
  const StrategyEngine();

  QScore evaluate(Strategy strategy) {
    int totalScore = 0;
    int maxScore = 0;

    final List<String> reasons = [];

    for (final Indicator indicator in strategy.indicators) {
      totalScore += indicator.calculate();
      maxScore += indicator.maxScore;
      reasons.addAll(indicator.reasons);
    }

    final double percentage =
        maxScore == 0 ? 0 : (totalScore / maxScore) * 100;

    return QScore(
      score: totalScore,
      maxScore: maxScore,
      percentage: percentage,
      reasons: reasons,
    );
  }
}