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
import 'engines/liquidity_sweep_engine.dart';
import 'engines/smart_money_engine.dart';

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
    required double bidPrice,
    required double askPrice,
    required int bidQuantity,
    required int askQuantity,
  }) {
    // ============================================================
    // PRICE STRUCTURE
    // ============================================================

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

    // ============================================================
    // MOMENTUM / STRENGTH
    // ============================================================

    final adx = ADXEngine.analyze(
      candles: candles,
    );

    final rsi = RSIEngine.analyze(
      candles: candles,
      direction: direction,
    );

    // ============================================================
    // PARTICIPATION
    // ============================================================

    final volume = VolumeEngine.analyze(
      candles: candles,
    );

    // ============================================================
    // LIQUIDITY
    // ============================================================

    final liquidity = LiquidityEngine.analyze(
      bidPrice: bidPrice,
      askPrice: askPrice,
      bidQuantity: bidQuantity.toDouble(),
      askQuantity: askQuantity.toDouble(),
    );

    final liquiditySweep = LiquiditySweepEngine.analyze(
      candles: candles,
    );

    final smartMoney = SmartMoneyEngine.analyze(
      candles: candles,
    );

    // ============================================================
    // MARKET VOLATILITY RISK
    // ============================================================

    final risk = RiskEngine.analyze(
      candles: candles,
    );

    // ============================================================
    // DERIVATIVES
    // ============================================================

    final option = OptionChainEngine.analyze(
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

    // ============================================================
    // MARKET BREADTH
    // ============================================================

    final breadth = HeatMapEngine.analyze(
      advancing: heatMap.advancing,
      declining: heatMap.declining,
    );

    // ============================================================
    // COMPOSITE MARKET HEALTH
    // ============================================================

    final marketHealth = MarketHealthEngine.analyze(
      trendScore: trend.score,
      emaScore: ema.score,
      adxScore: adx.score,
      rsiScore: rsi.score,
      riskScore: risk.score,
    );

    // ============================================================
    // DIRECTIONAL DERIVATIVE SCORING
    // ============================================================

    final directionalOIScore =
        QScoreEngine.directionalOIScore(
      bias: oi.bias,
      rawScore: oi.score,
      direction: direction,
    );

    final directionalBreadthScore =
        QScoreEngine.directionalBreadthScore(
      advancing: heatMap.advancing,
      declining: heatMap.declining,
      direction: direction,
    );

    // ============================================================
    // DATA AVAILABILITY
    // ============================================================

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

    final trendAvailable =
        trend.trend != 'Unknown' &&
        trend.score >= 0;

    final emaAvailable =
        ema.score >= 0;

    final adxAvailable =
        adx.score >= 0;

    final rsiAvailable =
        rsi.score >= 0;

    final liquiditySweepAvailable =
        liquiditySweep.detected;

    final smartMoneyAvailable =
        smartMoney.score > 0;

    // ============================================================
    // QUANTTORA Q-SCORE
    //
    // TOTAL WEIGHT = 100
    //
    // PRICE STRUCTURE = 30
    // Trend 13
    // EMA   10
    // VWAP   7
    //
    // MOMENTUM = 16
    // ADX 8
    // RSI 8
    //
    // PARTICIPATION = 9
    // Volume 9
    //
    // DERIVATIVES = 17
    // Option Chain 10
    // OI 7
    //
    // MARKET CONTEXT = 10
    // Breadth 5
    // Risk 5
    //
    // LIQUIDITY / SMART MONEY = 18
    // Liquidity Sweep 8
    // Smart Money 10
    //
    // Unavailable inputs are excluded and
    // remaining weights are normalized.
    // ============================================================

    final qScore = QScoreEngine.calculate(
      inputs: [
        QScoreInput(
          score: trend.score,
          weight: 13,
          available: trendAvailable,
        ),

        QScoreInput(
          score: ema.score,
          weight: 10,
          available: emaAvailable,
        ),

        QScoreInput(
          score: vwap.score,
          weight: 7,
          available: vwapAvailable,
        ),

        QScoreInput(
          score: adx.score,
          weight: 8,
          available: adxAvailable,
        ),

        QScoreInput(
          score: rsi.score,
          weight: 8,
          available: rsiAvailable,
        ),

        QScoreInput(
          score: volume.score,
          weight: 9,
          available: volumeAvailable,
        ),

        QScoreInput(
          score: option.score,
          weight: 10,
          available: optionAvailable,
        ),

        QScoreInput(
          score: directionalOIScore,
          weight: 7,
          available: oi.available,
        ),

        QScoreInput(
          score: directionalBreadthScore,
          weight: 5,
          available: breadthAvailable,
        ),

        QScoreInput(
          score: risk.score,
          weight: 5,
          available: riskAvailable,
        ),

        QScoreInput(
          score: liquiditySweep.score,
          weight: 8,
          available: liquiditySweepAvailable,
        ),

        QScoreInput(
          score: smartMoney.score,
          weight: 10,
          available: smartMoneyAvailable,
        ),
      ],
    );

    // ============================================================
    // DISPLAY TEXT
    // ============================================================

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

    // ============================================================
    // ANALYSIS REASONS
    // ============================================================

    final reasons = <String>[
      trend.reason,
      ema.reason,
      volume.reason,
      vwap.reason,
      adx.reason,
      rsi.reason,
      liquidity.reason,
      liquiditySweep.reason,
      smartMoney.reason,
      risk.reason,
      marketHealth.reason,
    ];

    if (optionAvailable) {
      reasons.add(option.reason);
    }

    if (oi.available) {
      reasons.add(oi.reason);
    }

    if (breadthAvailable) {
      reasons.add(breadth.reason);
    }

    if (sectorStrength.name != '-') {
      reasons.add(
        'Leading sector is '
        '${sectorStrength.name} at '
        '${sectorStrength.strength.toStringAsFixed(2)}%.',
      );
    }

    // Q-Score data coverage
    reasons.add(
      'Q-Score data coverage: '
      '${qScore.coveragePercent}%.',
    );

    // ============================================================
    // FINAL ANALYSIS RESULT
    // ============================================================

    return AnalysisResult(
      market: market,
      direction: direction,

      // Quanttora Q-Score
      confidence: qScore.score,

      marketHealth: marketHealth.score,

      trend: trend.trend,

      momentum: rsi.status,

      volume: volume.status,

      liquidity: liquidity.status,

      liquiditySweep: liquiditySweep.status,
      liquiditySweepScore: liquiditySweep.score,

      smartMoney: smartMoney.structure,
      smartMoneyScore: smartMoney.score,

      volatility: risk.level,

      sectorStrength: sectorText,

      heatMap: heatMapText,

      risk: risk.level,

      reasons: reasons,
    );
  }
}