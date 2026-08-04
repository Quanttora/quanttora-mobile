import '../../../features/trade_analysis/models/analysis_result.dart';
import '../../services/market_data_service.dart';

import '../analysis_engine.dart';

import 'orchestrator_result.dart';

class AnalysisOrchestrator {
  static Future<OrchestratorResult> analyze({
    required String market,
    required String direction,
  }) async {
    final marketDataService =
        MarketDataService();

    // FETCH REAL MARKET SNAPSHOT
    final snapshot =
        await marketDataService.fetchSnapshot(
      market: market,
      timeframe: '3 min',
    );

    // RUN ANALYSIS USING REAL MARKET DATA
    final AnalysisResult analysis =
        AnalysisEngine.analyze(
      market: market,
      direction: direction,
      candles: snapshot.candles,
      optionChain: snapshot.optionChain,
      oiData: snapshot.oiData,
      heatMap: snapshot.heatMap,
      sectorStrength: snapshot.sectorStrength,
    );

    // Global-market blocking is intentionally
    // disabled until genuine global/news data
    // is connected.
    return OrchestratorResult(
      analysis: analysis,
      blocked: false,
      blockReason: '',
    );
  }
}