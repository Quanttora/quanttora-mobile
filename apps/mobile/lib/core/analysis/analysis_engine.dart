import '../../features/trade_analysis/models/analysis_result.dart';
import '../market_data/models/candle.dart';

import 'engines/trend_engine.dart';
import 'engines/volume_engine.dart';
import 'engines/vwap_engine.dart';
import 'engines/adx_engine.dart';
import 'engines/rsi_engine.dart';
import 'engines/liquidity_engine.dart';
import 'engines/risk_engine.dart';
import 'engines/market_health_engine.dart';
import 'engines/ema/ema_engine.dart';

class AnalysisEngine {
  static AnalysisResult analyze({
    required String market,
    required String direction,
    required List<Candle> candles,
  }) {
    final trend = TrendEngine.analyze(
      market: market,
      direction: direction,
    );

    final volume = VolumeEngine.analyze(
      market: market,
    );

    final vwap = VWAPEngine.analyze(
      market: market,
      direction: direction,
    );

    final adx = ADXEngine.analyze();

    final rsi = RSIEngine.analyze(
  candles: candles,
  direction: direction,
);

    final liquidity = LiquidityEngine.analyze();

    final risk = RiskEngine.analyze();

    final marketHealth =
        MarketHealthEngine.analyze();

    // REAL EMA ANALYSIS
    final ema = EMAEngine.analyze(
      candles: candles,
      direction: direction,
    );

    final confidence = (
          trend.score +
          volume.score +
          vwap.score +
          adx.score +
          rsi.score +
          liquidity.score +
          risk.score +
          marketHealth.score +
          ema.score
        ) ~/
        9;

    return AnalysisResult(
      market: market,
      direction: direction,

      confidence: confidence,

      marketHealth: marketHealth.score,

      trend: trend.trend,

      momentum: rsi.status,

      volume: volume.status,

      liquidity: liquidity.status,

      volatility: "Healthy",

      sectorStrength: "Positive",

      heatMap: "Positive",

      risk: risk.level,

      reasons: [
        trend.reason,

        // REAL EMA REASON
        ema.reason,

        volume.reason,
        vwap.reason,
        adx.reason,
        rsi.reason,
        liquidity.reason,
        risk.reason,
        marketHealth.reason,
      ],
    );
  }
}