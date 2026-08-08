import 'constitution_result.dart';
import 'constitution_rule.dart';

class ConstitutionEngine {
  const ConstitutionEngine();

  ConstitutionResult evaluate({
    required int tradesToday,
    required int maxTradesPerDay,
    required double dailyLoss,
    required double maxDailyLoss,
    required double riskReward,
    required double minimumRiskReward,
  }) {
    final rules = <ConstitutionRule>[
      ConstitutionRule(
        id: 'max_trades',
        title: 'Maximum Trades',
        description: 'Maximum trades per day not exceeded.',
        status: tradesToday < maxTradesPerDay
            ? ConstitutionStatus.pass
            : ConstitutionStatus.fail,
      ),

      ConstitutionRule(
        id: 'daily_loss',
        title: 'Daily Loss',
        description: 'Daily loss is within allowed limit.',
        status: dailyLoss < maxDailyLoss
            ? ConstitutionStatus.pass
            : ConstitutionStatus.fail,
      ),

      ConstitutionRule(
        id: 'risk_reward',
        title: 'Risk Reward',
        description: 'Risk reward satisfies minimum requirement.',
        status: riskReward >= minimumRiskReward
            ? ConstitutionStatus.pass
            : ConstitutionStatus.fail,
      ),
    ];

    final failedRule = rules.cast<ConstitutionRule?>().firstWhere(
      (rule) => rule!.status == ConstitutionStatus.fail,
      orElse: () => null,
    );

    return ConstitutionResult(
      canAnalyze: failedRule == null,
      rules: rules,
      blockReason: failedRule?.title,
    );
  }
}
