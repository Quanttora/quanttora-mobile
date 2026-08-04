class OIResult {
  final String bias;
  final int score;
  final String reason;
  final bool available;

  const OIResult({
    required this.bias,
    required this.score,
    required this.reason,
    required this.available,
  });
}

class OIEngine {
  static OIResult analyze({
    required double callOIChange,
    required double putOIChange,
    required double callWriting,
    required double putWriting,
  }) {
    final totalActivity =
        callOIChange.abs() +
        putOIChange.abs();

    if (totalActivity == 0) {
      return const OIResult(
        bias: 'Unavailable',
        score: 0,
        reason: 'Real option OI change data is unavailable.',
        available: false,
      );
    }

    final putShare =
        putOIChange.abs() /
        totalActivity;

    final callShare =
        callOIChange.abs() /
        totalActivity;

    if (putWriting > callWriting) {
      return OIResult(
        bias: 'Bullish',
        score: (putShare * 100)
            .round()
            .clamp(0, 100),
        reason:
            'Put writing exceeds call writing in the live option chain.',
        available: true,
      );
    }

    if (callWriting > putWriting) {
      return OIResult(
        bias: 'Bearish',
        score: (callShare * 100)
            .round()
            .clamp(0, 100),
        reason:
            'Call writing exceeds put writing in the live option chain.',
        available: true,
      );
    }

    return const OIResult(
      bias: 'Neutral',
      score: 50,
      reason:
          'Call and put writing are balanced.',
      available: true,
    );
  }
}