class QScoreInput {
  final int score;
  final double weight;
  final bool available;

  const QScoreInput({
    required this.score,
    required this.weight,
    this.available = true,
  });
}

class QScoreResult {
  final int score;
  final double availableWeight;

  const QScoreResult({required this.score, required this.availableWeight});
}

class QScoreEngine {
  static QScoreResult calculate({required List<QScoreInput> inputs}) {
    final availableInputs = inputs.where((input) => input.available).toList();

    if (availableInputs.isEmpty) {
      return const QScoreResult(score: 0, availableWeight: 0);
    }

    double weightedTotal = 0;
    double availableWeight = 0;

    for (final input in availableInputs) {
      final normalizedScore = input.score.clamp(0, 100);

      weightedTotal += normalizedScore * input.weight;

      availableWeight += input.weight;
    }

    if (availableWeight <= 0) {
      return const QScoreResult(score: 0, availableWeight: 0);
    }

    final score = (weightedTotal / availableWeight).round().clamp(0, 100);

    return QScoreResult(score: score, availableWeight: availableWeight);
  }

  /// Converts market breadth into a score aligned
  /// with the requested CALL/PUT direction.
  static int directionalBreadthScore({
    required int advancing,
    required int declining,
    required String direction,
  }) {
    final total = advancing + declining;

    if (total <= 0) {
      return 0;
    }

    final normalizedDirection = direction.trim().toUpperCase();

    if (normalizedDirection == 'CALL') {
      return ((advancing / total) * 100).round().clamp(0, 100);
    }

    if (normalizedDirection == 'PUT') {
      return ((declining / total) * 100).round().clamp(0, 100);
    }

    return 0;
  }

  /// Converts raw OI bias strength into a score
  /// aligned with the requested CALL/PUT direction.
  static int directionalOIScore({
    required String bias,
    required int rawScore,
    required String direction,
  }) {
    final normalizedBias = bias.trim().toUpperCase();

    final normalizedDirection = direction.trim().toUpperCase();

    if (normalizedBias == 'NEUTRAL') {
      return 50;
    }

    final supportsDirection =
        (normalizedDirection == 'CALL' && normalizedBias == 'BULLISH') ||
        (normalizedDirection == 'PUT' && normalizedBias == 'BEARISH');

    if (supportsDirection) {
      return rawScore.clamp(0, 100);
    }

    final opposesDirection =
        (normalizedDirection == 'CALL' && normalizedBias == 'BEARISH') ||
        (normalizedDirection == 'PUT' && normalizedBias == 'BULLISH');

    if (opposesDirection) {
      return (100 - rawScore).clamp(0, 100);
    }

    return 50;
  }
}
