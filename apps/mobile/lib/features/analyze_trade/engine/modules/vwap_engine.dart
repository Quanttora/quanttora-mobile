import '../analysis_input.dart';
import 'engine_result.dart';

class VwapEngine {
  const VwapEngine();

  EngineResult evaluate(AnalysisInput input) {
    final passed = input.currentPrice > input.vwap;

    return EngineResult(
      title: "VWAP",
      passed: passed,
      score: passed ? 15 : 0,
      reason: passed
          ? "Price is above VWAP."
          : "Price is below VWAP.",
    );
  }
}