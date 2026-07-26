import '../analysis_input.dart';
import 'engine_result.dart';

class EmaEngine {
  const EmaEngine();

  EngineResult evaluate(AnalysisInput input) {
    final passed = input.currentPrice > input.ema20;

    return EngineResult(
      title: "EMA",
      passed: passed,
      score: passed ? 10 : 0,
      reason: passed
          ? "Price is above EMA."
          : "Price is below EMA.",
    );
  }
}