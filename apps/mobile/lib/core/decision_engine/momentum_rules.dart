class MomentumRules {
  final bool adxAbove25;
  final bool rsiHealthy;
  final bool volumeAboveAverage;
  final bool strongCandle;

  const MomentumRules({
    required this.adxAbove25,
    required this.rsiHealthy,
    required this.volumeAboveAverage,
    required this.strongCandle,
  });

  int calculateScore() {
    int score = 0;

    if (adxAbove25) score += 5;
    if (rsiHealthy) score += 5;
    if (volumeAboveAverage) score += 5;
    if (strongCandle) score += 5;

    return score;
  }

  List<String> reasons() {
    final List<String> list = [];

    if (adxAbove25) {
      list.add("ADX above 25");
    }

    if (rsiHealthy) {
      list.add("RSI is healthy");
    }

    if (volumeAboveAverage) {
      list.add("Volume is above average");
    }

    if (strongCandle) {
      list.add("Strong confirmation candle");
    }

    return list;
  }
}
