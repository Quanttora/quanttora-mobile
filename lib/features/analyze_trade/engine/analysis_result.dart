class AnalysisResult {
  final int score;

  final String verdict;

  final List<String> passed;

  final List<String> failed;

  final List<String> reasons;

  const AnalysisResult({
    required this.score,
    required this.verdict,
    required this.passed,
    required this.failed,
    required this.reasons,
  });
}