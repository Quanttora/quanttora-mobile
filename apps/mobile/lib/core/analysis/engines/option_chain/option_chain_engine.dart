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
    required double maxCallOI,
    required double maxPutOI,
    required double callVolume,
    required double putVolume,
    required double callOIChange,
    required double putOIChange,
    required double callWriting,
    required double putWriting,
    required String direction,
  }) {
    if (pcr <= 0) {
      return const OptionChainResult(
        pcr: 0,
        bias: 'Neutral',
        score: 50,
        reason: 'Option-chain data is unavailable.',
      );
    }

    int bullishPoints = 0;
    int bearishPoints = 0;

    final reasons = <String>[];

    // PCR
    if (pcr >= 1.05) {
      bullishPoints += 3;
      reasons.add(
        'PCR ${pcr.toStringAsFixed(2)} supports bullish positioning.',
      );
    } else if (pcr <= 0.95) {
      bearishPoints += 3;
      reasons.add(
        'PCR ${pcr.toStringAsFixed(2)} supports bearish positioning.',
      );
    } else {
      reasons.add(
        'PCR ${pcr.toStringAsFixed(2)} is broadly neutral.',
      );
    }

    // OPTION VOLUME
    if (putVolume > callVolume) {
      bullishPoints += 2;
      reasons.add(
        'Put-side volume is stronger than call-side volume.',
      );
    } else if (callVolume > putVolume) {
      bearishPoints += 2;
      reasons.add(
        'Call-side volume is stronger than put-side volume.',
      );
    }

    // OI CHANGE
    if (putOIChange > callOIChange) {
      bullishPoints += 2;
      reasons.add(
        'Put OI build-up is stronger than Call OI build-up.',
      );
    } else if (callOIChange > putOIChange) {
      bearishPoints += 2;
      reasons.add(
        'Call OI build-up is stronger than Put OI build-up.',
      );
    }

    // WRITING
    if (putWriting > callWriting) {
      bullishPoints += 3;
      reasons.add(
        'Put writing is stronger than Call writing.',
      );
    } else if (callWriting > putWriting) {
      bearishPoints += 3;
      reasons.add(
        'Call writing is stronger than Put writing.',
      );
    }

    String bias;

    if (bullishPoints > bearishPoints) {
      bias = 'Bullish';
    } else if (bearishPoints > bullishPoints) {
      bias = 'Bearish';
    } else {
      bias = 'Neutral';
    }

    final normalizedDirection =
        direction.trim().toUpperCase();

    final wantsBullish =
        normalizedDirection == 'CALL';

    final wantsBearish =
        normalizedDirection == 'PUT';

    int score;

    if (bias == 'Neutral') {
      score = 55;
    } else if (
        (bias == 'Bullish' && wantsBullish) ||
        (bias == 'Bearish' && wantsBearish)) {
      final strength =
          (bullishPoints - bearishPoints).abs();

      score = 70 + (strength * 3);

      if (score > 95) {
        score = 95;
      }
    } else {
      final strength =
          (bullishPoints - bearishPoints).abs();

      score = 45 - (strength * 3);

      if (score < 20) {
        score = 20;
      }
    }

    final callResistance =
        maxCallOI > 0
            ? maxCallOI.toStringAsFixed(0)
            : '-';

    final putSupport =
        maxPutOI > 0
            ? maxPutOI.toStringAsFixed(0)
            : '-';

    reasons.add(
      'Major Call OI resistance: $callResistance; '
      'major Put OI support: $putSupport.',
    );

    return OptionChainResult(
      pcr: pcr,
      bias: bias,
      score: score,
      reason: reasons.join(' '),
    );
  }
}