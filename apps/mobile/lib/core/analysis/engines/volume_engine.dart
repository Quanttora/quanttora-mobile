class VolumeResult {
  final String status;
  final int score;
  final String reason;

  const VolumeResult({
    required this.status,
    required this.score,
    required this.reason,
  });
}

class VolumeEngine {
  static VolumeResult analyze({
    required String market,
  }) {

    // Temporary logic
    // Future:
    // Current Candle Volume
    // 20 EMA Volume
    // Relative Volume (RVOL)
    // Delivery %
    // Option Volume

    return const VolumeResult(
      status: "High",
      score: 87,
      reason: "Volume is above the 20-period average.",
    );
  }
}