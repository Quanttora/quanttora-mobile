class AnalysisResult {
  final String market;
  final String direction;

  final int confidence;

  final int marketHealth;

  final String trend;

  final String momentum;

  final String volume;

  final String liquidity;

  final String volatility;

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
    required this.volume,
    required this.liquidity,
    required this.volatility,
    required this.sectorStrength,
    required this.heatMap,
    required this.risk,
    required this.reasons,
  });
}