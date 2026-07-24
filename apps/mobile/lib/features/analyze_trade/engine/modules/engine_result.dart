class EngineResult {
  final String title;

  final bool passed;

  final int score;

  final String reason;

  const EngineResult({
    required this.title,
    required this.passed,
    required this.score,
    required this.reason,
  });
}