class AnalysisResult {
  final String market;
  final String direction;

  final int confidence;

  final int marketHealth;

  final String trend;

  final String momentum;

  // ============================================================
  // VOLUME
  // ============================================================

  final String volume;

  final double currentVolume;

  final double averageVolume;

  final double relativeVolume;

  // ============================================================
  // VWAP
  // ============================================================

  final double currentPrice;

  final double vwapValue;

  final String vwapStatus;

  final bool priceAboveVwap;

  final int vwapScore;

  // ============================================================
  // MARKET RISK / VOLATILITY
  // ============================================================

  final String volatility;

  final double averageRangePercent;

  final double currentRangePercent;

  // ============================================================
  // OTHER ANALYSIS
  // ============================================================

  final String liquidity;

  final String liquiditySweep;

  final int liquiditySweepScore;

  final String smartMoney;

  final int smartMoneyScore;

  final String sectorStrength;

  final String heatMap;

  final String risk;

  final List<String> reasons;

  const AnalysisResult({
    required this.market,
    required this.direction,
    required this.confidence,
    required this.marketHealth,
    required this.trend,
    required this.momentum,

    // Volume
    required this.volume,
    required this.currentVolume,
    required this.averageVolume,
    required this.relativeVolume,

    // VWAP
    required this.currentPrice,
    required this.vwapValue,
    required this.vwapStatus,
    required this.priceAboveVwap,
    required this.vwapScore,

    // Market risk / volatility
    required this.volatility,
    required this.averageRangePercent,
    required this.currentRangePercent,

    // Other analysis
    required this.liquidity,
    required this.liquiditySweep,
    required this.liquiditySweepScore,
    required this.smartMoney,
    required this.smartMoneyScore,
    required this.sectorStrength,
    required this.heatMap,
    required this.risk,
    required this.reasons,
  });
}
