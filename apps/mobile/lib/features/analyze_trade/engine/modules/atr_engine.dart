import '../analysis_input.dart';
import 'engine_result.dart';

class AtrEngine {
  const AtrEngine();

  EngineResult evaluate(AnalysisInput input) {
    final passed = input.atr > 0;

    return EngineResult(
      title: "ATR",
      passed: passed,
      score: passed ? 10 : 0,
      reason: passed
          ? "Volatility is sufficient."
          : "Low volatility detected.",
    );
  }
}