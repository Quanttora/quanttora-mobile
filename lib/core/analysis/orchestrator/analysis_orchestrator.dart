import '../../../features/trade_analysis/models/analysis_result.dart';

import '../analysis_engine.dart';

import '../engines/global/global_market_engine.dart';

import 'orchestrator_result.dart';

class AnalysisOrchestrator {

  static Future<OrchestratorResult> analyze({

    required String market,

    required String direction,

  }) async {

    final global = GlobalMarketEngine.analyze(

      sp500: 0.80,

      nasdaq: 1.15,

      dow: 0.55,

      crude: 1.40,

      dxy: 104.20,

      indiaVix: 14.80,

      fedEvent: false,

      rbiEvent: false,

      majorNews: false,

    );

    final AnalysisResult analysis = AnalysisEngine.analyze(

      market: market,

      direction: direction,

    );

    if (global.riskDetected) {

      return OrchestratorResult(

        analysis: analysis,

        blocked: true,

        blockReason:
            "High global market risk detected. AI analysis temporarily paused.",

      );

    }

    return OrchestratorResult(

      analysis: analysis,

      blocked: false,

      blockReason: "",

    );

  }

}