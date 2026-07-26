import '../analysis_input.dart';
import 'engine_result.dart';

class RsiEngine {
  const RsiEngine();

  EngineResult evaluate(AnalysisInput input) {
    final passed = input.rsi >= 55 && input.rsi <= 70;

    return EngineResult(
      title: "RSI",
      passed: passed,
      score: passed ? 15 : 0,
      reason: passed
          ? "RSI confirms bullish momentum."
          : "RSI confirmation failed.",
    );
  }
}