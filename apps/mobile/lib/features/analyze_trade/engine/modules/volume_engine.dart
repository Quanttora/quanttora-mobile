import '../analysis_input.dart';
import 'engine_result.dart';

class VolumeEngine {
  const VolumeEngine();

  EngineResult evaluate(AnalysisInput input) {
    final passed = input.volume > input.averageVolume;

    return EngineResult(
      title: "Volume",
      passed: passed,
      score: passed ? 15 : 0,
      reason: passed
          ? "Volume is above average."
          : "Volume is below average.",
    );
  }
}