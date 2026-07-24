import '../analysis_input.dart';
import 'engine_result.dart';

class ConstitutionEngine {
  const ConstitutionEngine();

  EngineResult evaluate(AnalysisInput input) {
    return EngineResult(
      title: "Trading Constitution",
      passed: input.constitutionPassed,
      score: input.constitutionPassed ? 10 : 0,
      reason: input.constitutionPassed
          ? "Constitution rules passed."
          : "Constitution rules violated.",
    );
  }
}