class LiquidityResult {
  final String status;
  final int score;
  final String reason;
  final bool available;

  const LiquidityResult({
    required this.status,
    required this.score,
    required this.reason,
    required this.available,
  });
}

class LiquidityEngine {
  static LiquidityResult analyze({
    double? bidPrice,
    double? askPrice,
    double? bidQuantity,
    double? askQuantity,
  }) {
    if (bidPrice == null ||
        askPrice == null ||
        bidQuantity == null ||
        askQuantity == null ||
        bidPrice <= 0 ||
        askPrice <= 0 ||
        bidQuantity <= 0 ||
        askQuantity <= 0 ||
        askPrice < bidPrice) {
      return const LiquidityResult(
        status: 'Unavailable',
        score: 0,
        reason: 'Real bid-ask market depth is unavailable for this instrument.',
        available: false,
      );
    }

    final midPrice = (bidPrice + askPrice) / 2;

    if (midPrice <= 0) {
      return const LiquidityResult(
        status: 'Unavailable',
        score: 0,
        reason:
            'Unable to calculate liquidity from the available market depth.',
        available: false,
      );
    }

    final spread = askPrice - bidPrice;

    final spreadPercent = (spread / midPrice) * 100;

    final totalDepth = bidQuantity + askQuantity;

    final int score;
    final String status;

    if (spreadPercent <= 0.05 && totalDepth >= 1000) {
      score = 95;
      status = 'Excellent';
    } else if (spreadPercent <= 0.10 && totalDepth >= 500) {
      score = 85;
      status = 'Good';
    } else if (spreadPercent <= 0.25) {
      score = 65;
      status = 'Moderate';
    } else {
      score = 35;
      status = 'Poor';
    }

    return LiquidityResult(
      status: status,
      score: score,
      reason:
          'Bid-ask spread is ${spreadPercent.toStringAsFixed(3)}% '
          'with combined visible depth of '
          '${totalDepth.toStringAsFixed(0)}.',
      available: true,
    );
  }
}
