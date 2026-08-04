import 'decision_result.dart';
import 'market_rules.dart';
import 'momentum_rules.dart';
import 'risk_rules.dart';
import 'strategy_rules.dart';
import 'psychology_rules.dart';

class DecisionEngine {
  final MarketRules market;
  final MomentumRules momentum;
  final RiskRules risk;
  final StrategyRules strategy;
  final PsychologyRules psychology;

  const DecisionEngine({
    required this.market,
    required this.momentum,
    required this.risk,
    required this.strategy,
    required this.psychology,
  });

    DecisionResult evaluate() {
    final marketScore = market.calculateScore();
    final momentumScore = momentum.calculateScore();
    final riskScore = risk.calculateScore();
    final strategyScore = strategy.calculateScore();
    final psychologyScore = psychology.calculateScore();

    final total = marketScore +
        momentumScore +
        riskScore +
        strategyScore +
        psychologyScore;

    final DecisionVerdict verdict;

    if (total >= 90) {
      verdict = DecisionVerdict.execute;
    } else if (total >= 75) {
      verdict = DecisionVerdict.wait;
    } else if (total >= 60) {
      verdict = DecisionVerdict.highRisk;
    } else {
      verdict = DecisionVerdict.avoid;
    }

    return DecisionResult(
      totalScore: total,
      marketScore: marketScore,
      momentumScore: momentumScore,
      riskScore: riskScore,
      strategyScore: strategyScore,
      psychologyScore: psychologyScore,
      verdict: verdict,
      reasons: [
        ...market.reasons(),
        ...momentum.reasons(),
        ...risk.reasons(),
        ...strategy.reasons(),
        ...psychology.reasons(),
      ],
    );
  }
}