import 'policy_result.dart';

class DecisionPolicy {
  const DecisionPolicy._();

  static PolicyResult evaluate({
    required int aiConfidence,
    required int minimumAiScore,
    required bool avoidSidewaysMarket,
    required bool avoidLowVolume,
    required bool avoidNews,
    required bool newsDataAvailable,
    required bool highImpactNews,
    required String trend,
    required String volume,
    required int tradesToday,
    required int maxTradesPerDay,
  }) {
    final blockingReasons = <String>[];
    final passedRules = <String>[];

    // ============================================================
    // AI SCORE GATE
    // ============================================================

    if (minimumAiScore > 0) {
      if (aiConfidence < minimumAiScore) {
        blockingReasons.add(
          'AI confidence $aiConfidence% is below the '
          'strategy minimum of $minimumAiScore%.',
        );
      } else {
        passedRules.add('AI confidence requirement passed.');
      }
    }

    // ============================================================
    // SIDEWAYS MARKET GATE
    // ============================================================

    if (avoidSidewaysMarket) {
      if (trend == 'Sideways') {
        blockingReasons.add(
          'Strategy does not allow trading in a sideways market.',
        );
      } else if (trend == 'Unknown') {
        blockingReasons.add('Market trend could not be determined reliably.');
      } else {
        passedRules.add('Sideways market filter passed.');
      }
    }

    // ============================================================
    // LOW VOLUME GATE
    // ============================================================

    if (avoidLowVolume) {
      if (volume == 'Low') {
        blockingReasons.add(
          'Strategy does not allow trading in low-volume conditions.',
        );
      } else if (volume == 'N/A (Index Instrument)') {
        // Index instruments such as NIFTY 50, BANK NIFTY and
        // SENSEX do not provide exchange traded volume.
        //
        // This is NOT the same as low volume.
        // Do not block an index trade merely because volume
        // does not exist for the underlying index.
        passedRules.add(
          'Volume filter passed: index instrument does not '
          'provide exchange traded volume.',
        );
      } else if (volume == 'Volume Unavailable' ||
          volume == 'Insufficient Data') {
        blockingReasons.add(
          'Reliable volume data is unavailable, so the '
          'strategy volume rule cannot be verified.',
        );
      } else {
        passedRules.add('Volume filter passed.');
      }
    }

    // ============================================================
    // NEWS SAFETY GATE
    // ============================================================

    if (avoidNews) {
      if (!newsDataAvailable) {
        blockingReasons.add(
          'Reliable news-safety data is unavailable, so the '
          'strategy news rule cannot be verified.',
        );
      } else if (highImpactNews) {
        blockingReasons.add('High-impact market-moving news risk detected.');
      } else {
        passedRules.add('News safety filter passed.');
      }
    }

    // ============================================================
    // MAX TRADES PER DAY GATE
    // ============================================================

    if (maxTradesPerDay > 0) {
      if (tradesToday >= maxTradesPerDay) {
        blockingReasons.add(
          'Daily trade limit reached: '
          '$tradesToday/$maxTradesPerDay trades used.',
        );
      } else {
        passedRules.add(
          'Daily trade limit passed: '
          '$tradesToday/$maxTradesPerDay trades used.',
        );
      }
    }

    return PolicyResult(
      allowed: blockingReasons.isEmpty,
      blockingReasons: blockingReasons,
      passedRules: passedRules,
    );
  }
}
