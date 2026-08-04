import '../../features/trade_analysis/models/analysis_result.dart';

import '../market_data/models/candle.dart';
import '../market_data/models/heat_map.dart';
import '../market_data/models/oi_data.dart';
import '../market_data/models/option_chain.dart';
import '../market_data/models/sector_strength.dart';

import 'engines/trend_engine.dart';
import 'engines/volume_engine.dart';
import 'engines/vwap_engine.dart';
import 'engines/adx_engine.dart';
import 'engines/rsi_engine.dart';
import 'engines/liquidity_engine.dart';
import 'engines/risk_engine.dart';
import 'engines/market_health_engine.dart';

import 'engines/ema/ema_engine.dart';
import 'engines/heat_map/heat_map_engine.dart';
import 'engines/option_chain/option_chain_engine.dart';
import 'engines/oi/oi_engine.dart';
import 'engines/q_score/q_score_engine.dart';

class AnalysisEngine {
  static AnalysisResult analyze({
    required String market,
    required String direction,
    required List<Candle> candles,
    required OptionChain optionChain,
    required OIData oiData,
    required HeatMap heatMap,
    required SectorStrength sectorStrength,
  }) {
    // PRICE STRUCTURE
    final trend = TrendEngine.analyze(
      candles: candles,
      direction: direction,
    );

    final ema = EMAEngine.analyze(
      candles: candles,
      direction: direction,
    );

    final vwap = VWAPEngine.analyze(
      candles: candles,
      direction: direction,
    );

    // MOMENTUM / STRENGTH
    final adx = ADXEngine.analyze(
      candles: candles,
    );

    final rsi = RSIEngine.analyze(
      candles: candles,
      direction: direction,
    );

    // PARTICIPATION
    final volume = VolumeEngine.analyze(
      candles: candles,
    );

    // LIQUIDITY
    // Excluded from Q-Score until genuine
    // bid/ask market depth is available.
    final liquidity =
        LiquidityEngine.analyze();

    // MARKET VOLATILITY RISK
    final risk = RiskEngine.analyze(
      candles: candles,
    );

    // DERIVATIVES
    final option =
        OptionChainEngine.analyze(
      pcr: optionChain.pcr,
      maxCallOI: optionChain.maxCallOI,
      maxPutOI: optionChain.maxPutOI,
      callVolume: optionChain.callVolume,
      putVolume: optionChain.putVolume,
      callOIChange: oiData.callOIChange,
      putOIChange: oiData.putOIChange,
      callWriting: oiData.callWriting,
      putWriting: oiData.putWriting,
      direction: direction,
    );

    final oi = OIEngine.analyze(
      callOIChange: oiData.callOIChange,
      putOIChange: oiData.putOIChange,
      callWriting: oiData.callWriting,
      putWriting: oiData.putWriting,
    );

    // MARKET BREADTH
    final breadth =
        HeatMapEngine.analyze(
      advancing: heatMap.advancing,
      declining: heatMap.declining,
    );

    // COMPOSITE MARKET HEALTH
    final marketHealth =
        MarketHealthEngine.analyze(
      trendScore: trend.score,
      emaScore: ema.score,
      adxScore: adx.score,
      rsiScore: rsi.score,
      riskScore: risk.score,
    );

    // Direction-align raw OI strength.
    final directionalOIScore =
        QScoreEngine.directionalOIScore(
      bias: oi.bias,
      rawScore: oi.score,
      direction: direction,
    );

    // Direction-align market breadth.
    final directionalBreadthScore =
        QScoreEngine.directionalBreadthScore(
      advancing: heatMap.advancing,
      declining: heatMap.declining,
      direction: direction,
    );

    final volumeAvailable =
        volume.status != 'Volume Unavailable' &&
        volume.status != 'Insufficient Data';

    final vwapAvailable =
        vwap.status != 'Unavailable' &&
        vwap.status != 'Insufficient Data';

    final optionAvailable =
        optionChain.pcr > 0;

    final breadthAvailable =
        breadth.sentiment != 'Unavailable';

    final riskAvailable =
        risk.level != 'Unknown';

    // PERMANENT WEIGHTED Q-SCORE
    //
    // PRICE STRUCTURE = 35%
    // Trend 15 + EMA 12 + VWAP 8
    //
    // MOMENTUM = 20%
    // ADX 10 + RSI 10
    //
    // PARTICIPATION = 10%
    // Volume 10
    //
    // DERIVATIVES = 20%
    // Option Chain 12 + OI 8
    //
    // MARKET CONTEXT = 15%
    // Breadth 8 + Volatility Risk 7
    //
    // Unavailable inputs are excluded and
    // remaining weights are normalized.
    final qScore =
        QScoreEngine.calculate(
      inputs: [
        QScoreInput(
          score: trend.score,
          weight: 15,
          available: trend.score > 0,
        ),
        QScoreInput(
          score: ema.score,
          weight: 12,
          available: ema.score > 0,
        ),
        QScoreInput(
          score: vwap.score,
          weight: 8,
          available: vwapAvailable,
        ),
        QScoreInput(
          score: adx.score,
          weight: 10,
          available: adx.score > 0,
        ),
        QScoreInput(
          score: rsi.score,
          weight: 10,
          available: rsi.score > 0,
        ),
        QScoreInput(
          score: volume.score,
          weight: 10,
          available: volumeAvailable,
        ),
        QScoreInput(
          score: option.score,
          weight: 12,
          available: optionAvailable,
        ),
        QScoreInput(
          score: directionalOIScore,
          weight: 8,
          available: oi.available,
        ),
        QScoreInput(
          score: directionalBreadthScore,
          weight: 8,
          available: breadthAvailable,
        ),
        QScoreInput(
          score: risk.score,
          weight: 7,
          available: riskAvailable,
        ),
      ],
    );

    final sectorText =
        sectorStrength.name == '-'
            ? 'Unavailable'
            : '${sectorStrength.name} '
                '${sectorStrength.strength.toStringAsFixed(2)}%';

    final heatMapText =
        breadth.sentiment == 'Unavailable'
            ? 'Unavailable'
            : '${breadth.sentiment} '
                '(${heatMap.advancing} up / '
                '${heatMap.declining} down)';

    final reasons = <String>[
      trend.reason,
      ema.reason,
      volume.reason,
      vwap.reason,
      adx.reason,
      rsi.reason,
      liquidity.reason,
      risk.reason,
      marketHealth.reason,
    ];

    if (optionAvailable) {
      reasons.add(
        option.reason,
      );
    }

    if (oi.available) {
      reasons.add(
        oi.reason,
      );
    }

    if (breadthAvailable) {
      reasons.add(
        breadth.reason,
      );
    }

    if (sectorStrength.name != '-') {
      reasons.add(
        'Leading sector is '
        '${sectorStrength.name} at '
        '${sectorStrength.strength.toStringAsFixed(2)}%.',
      );
    }

    return AnalysisResult(
      market: market,
      direction: direction,

      // confidence currently represents
      // Quanttora's weighted Q-Score.
      confidence: qScore.score,

      marketHealth: marketHealth.score,
      trend: trend.trend,
      momentum: rsi.status,
      volume: volume.status,
      liquidity: liquidity.status,
      volatility: risk.level,
      sectorStrength: sectorText,
      heatMap: heatMapText,
      risk: risk.level,
      reasons: reasons,
    );
  }
}