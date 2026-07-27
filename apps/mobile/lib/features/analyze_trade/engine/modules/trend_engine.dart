import '../analysis_input.dart';
import 'engine_result.dart';

class TrendEngine {
  const TrendEngine();

  EngineResult evaluate(AnalysisInput input) {
    return const EngineResult(
      title: 'Trend',
      passed: true,
      score: 10,
      reason: 'Trend Engine placeholder.',
    );
  }
}