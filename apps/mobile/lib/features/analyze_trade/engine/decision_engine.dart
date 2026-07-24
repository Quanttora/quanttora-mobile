import 'analysis_input.dart';
import 'analysis_result.dart';

import 'modules/atr_engine.dart';
import 'modules/constitution_engine.dart';
import 'modules/ema_engine.dart';
import 'modules/engine_result.dart';
import 'modules/risk_reward_engine.dart';
import 'modules/rsi_engine.dart';
import 'modules/trend_engine.dart';
import 'modules/volume_engine.dart';
import 'modules/vwap_engine.dart';

class DecisionEngine {
  const DecisionEngine();

  AnalysisResult analyze(AnalysisInput input) {
    final List<EngineResult> results = [
      const TrendEngine().evaluate(input),
      const EmaEngine().evaluate(input),
      const VwapEngine().evaluate(input),
      const RsiEngine().evaluate(input),
      const VolumeEngine().evaluate(input),
      const AtrEngine().evaluate(input),
      const RiskRewardEngine().evaluate(input),
      const ConstitutionEngine().evaluate(input),
    ];

    int totalScore = 0;

    final passed = <String>[];
    final failed = <String>[];
    final reasons = <String>[];

    for (final result in results) {
      totalScore += result.score;

      if (result.passed) {
        passed.add(result.title);
      } else {
        failed.add(result.title);
      }

      reasons.add(result.reason);
    }

    final verdict = _getVerdict(totalScore);

    return AnalysisResult(
      score: totalScore,
      verdict: verdict,
      passed: passed,
      failed: failed,
      reasons: reasons,
    );
  }

  String _getVerdict(int score) {
    if (score >= 80) {
      return "EXECUTE";
    }

    if (score >= 60) {
      return "WAIT";
    }

    return "AVOID";
  }
}