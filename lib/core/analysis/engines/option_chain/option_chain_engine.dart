class OptionChainResult {
  final double pcr;
  final String bias;
  final int score;
  final String reason;

  const OptionChainResult({
    required this.pcr,
    required this.bias,
    required this.score,
    required this.reason,
  });
}

class OptionChainEngine {
  static OptionChainResult analyze({
    required double pcr,
  }) {

    if (pcr > 1.0) {
      return OptionChainResult(
        pcr: pcr,
        bias: "Bullish",
        score: 90,
        reason: "PCR supports bullish sentiment.",
      );
    }

    return OptionChainResult(
      pcr: pcr,
      bias: "Bearish",
      score: 75,
      reason: "PCR indicates bearish sentiment.",
    );
  }
}