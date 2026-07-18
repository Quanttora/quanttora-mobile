class GlobalMarketResult {
  final bool riskDetected;

  final int score;

  final String sentiment;

  final List<String> warnings;

  const GlobalMarketResult({
    required this.riskDetected,
    required this.score,
    required this.sentiment,
    required this.warnings,
  });
}