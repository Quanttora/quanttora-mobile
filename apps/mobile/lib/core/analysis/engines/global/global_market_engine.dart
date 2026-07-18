import 'global_market_result.dart';

class GlobalMarketEngine {

  static GlobalMarketResult analyze({

    required double sp500,

    required double nasdaq,

    required double dow,

    required double crude,

    required double dxy,

    required double indiaVix,

    required bool fedEvent,

    required bool rbiEvent,

    required bool majorNews,

  }) {

    int score = 100;

    List<String> warnings = [];

    if (fedEvent) {
      score -= 20;
      warnings.add("Federal Reserve event scheduled.");
    }

    if (rbiEvent) {
      score -= 20;
      warnings.add("RBI event scheduled.");
    }

    if (majorNews) {
      score -= 20;
      warnings.add("High impact global news.");
    }

    if (indiaVix > 18) {
      score -= 15;
      warnings.add("India VIX elevated.");
    }

    if (crude > 2) {
      score -= 10;
      warnings.add("Crude oil volatility rising.");
    }

    if (dxy > 105) {
      score -= 5;
      warnings.add("Strong US Dollar.");
    }

    if (score < 0) {
      score = 0;
    }

    final sentiment = score >= 80
        ? "Positive"
        : score >= 60
            ? "Neutral"
            : "Risky";

    return GlobalMarketResult(
      riskDetected: score < 60,
      score: score,
      sentiment: sentiment,
      warnings: warnings,
    );
  }
}