import '../analysis_input.dart';
import 'engine_result.dart';

class RiskRewardEngine {
  const RiskRewardEngine();

  EngineResult evaluate(AnalysisInput input) {
    final risk = input.entryPrice - input.stopLoss;
    final reward = input.target - input.entryPrice;

    final ratio = risk > 0 ? reward / risk : 0;

    final passed = ratio >= 2;

    return EngineResult(
      title: "Risk Reward",
      passed: passed,
      score: passed ? 15 : 0,
      reason: passed
          ? "Risk Reward = ${ratio.toStringAsFixed(2)}"
          : "Risk Reward too low (${ratio.toStringAsFixed(2)})",
    );
  }
}