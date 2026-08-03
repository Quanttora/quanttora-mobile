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
    // REAL TREND
    final trend = TrendEngine.analyze(
      candles: candles,
      direction: direction,
    );

    // REAL VOLUME
    final volume = VolumeEngine.analyze(
      candles: candles,
    );

    // REAL VWAP
    final vwap = VWAPEngine.analyze(
      candles: candles,
      direction: direction,
    );

    // REAL ADX
    final adx = ADXEngine.analyze(
      candles: candles,
    );

    // REAL RSI
    final rsi = RSIEngine.analyze(
      candles: candles,
      direction: direction,
    );

    // LIQUIDITY
    // Real bid/ask depth will be supplied when
    // tradable option/futures instruments are connected.
    final liquidity = LiquidityEngine.analyze();

    // REAL MARKET-CONDITION RISK
    final risk = RiskEngine.analyze(
      candles: candles,
    );

    // REAL EMA
    final ema = EMAEngine.analyze(
      candles: candles,
      direction: direction,
    );

    // REAL COMPOSITE MARKET HEALTH
    final marketHealth = MarketHealthEngine.analyze(
      trendScore: trend.score,
      emaScore: ema.score,
      adxScore: adx.score,
      rsiScore: rsi.score,
      riskScore: risk.score,
    );

    // Only reliable/available inputs participate
    // in final confidence.
    final scores = <int>[
      trend.score,
      adx.score,
      rsi.score,
      risk.score,
      ema.score,
    ];

    // Index candles can have zero volume.
    if (volume.status != 'Volume Unavailable' &&
        volume.status != 'Insufficient Data') {
      scores.add(volume.score);
    }

    // VWAP requires genuine volume.
    if (vwap.status != 'Unavailable' &&
        vwap.status != 'Insufficient Data') {
      scores.add(vwap.score);
    }

    // Liquidity requires genuine bid/ask depth.
    if (liquidity.available) {
      scores.add(liquidity.score);
    }

    final confidence = scores.isEmpty
        ? 0
        : scores.reduce((a, b) => a + b) ~/
            scores.length;

    return AnalysisResult(
      market: market,
      direction: direction,

      confidence: confidence,

      marketHealth: marketHealth.score,

      trend: trend.trend,

      momentum: rsi.status,

      volume: volume.status,

      liquidity: liquidity.status,

      volatility: risk.level,

      sectorStrength: "Unavailable",

      heatMap: "Unavailable",

      risk: risk.level,

      reasons: [
        trend.reason,
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
