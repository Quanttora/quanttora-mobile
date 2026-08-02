class EMAResult {
  final bool ema22Above33;
  final bool priceAbove22;
  final bool aligned;
  final int score;
  final String reason;

  const EMAResult({
    required this.ema22Above33,
    required this.priceAbove22,
    required this.aligned,
    required this.score,
    required this.reason,
  });
}

class EMAEngine {
  static EMAResult analyze({
    required double ema22,
    required double ema33,
    required double currentPrice,
  }) {
    final ema22Above33 = ema22 > ema33;
    final priceAbove22 = currentPrice > ema22;
    final aligned = ema22Above33 && priceAbove22;

    return EMAResult(
      ema22Above33: ema22Above33,
      priceAbove22: priceAbove22,
      aligned: aligned,
      score: aligned ? 95 : 45,
      reason: aligned
          ? "EMA alignment confirms trend."
          : "EMA alignment is weak.",
    );
  }
}