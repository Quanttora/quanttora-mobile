class ConfidenceEngine {
  static int calculate({
    required List<int> scores,
  }) {

    if (scores.isEmpty) return 0;

    final total = scores.reduce((a, b) => a + b);

    return (total / scores.length).round();
  }
}