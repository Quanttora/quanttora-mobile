class VWAPResult {
  final bool aboveVWAP;
  final int score;
  final String status;
  final String reason;

  const VWAPResult({
    required this.aboveVWAP,
    required this.score,
    required this.status,
    required this.reason,
  });
}

class VWAPEngine {
  static VWAPResult analyze({
    required String market,
    required String direction,
  }) {

    // Future:
    // Live VWAP
    // Price Position
    // VWAP Slope

    if (direction == "CALL") {
      return const VWAPResult(
        aboveVWAP: true,
        score: 90,
        status: "Above VWAP",
        reason: "Price is trading above VWAP.",
      );
    }

    return const VWAPResult(
      aboveVWAP: false,
      score: 90,
      status: "Below VWAP",
      reason: "Price is trading below VWAP.",
    );
  }
}