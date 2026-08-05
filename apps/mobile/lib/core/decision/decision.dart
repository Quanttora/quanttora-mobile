import '../scoring/q_score.dart';

class Decision {
  final QScore score;

  final String marketReadiness;

  final String capitalProtection;

  final double probability;

  final bool strategyAligned;

  final List<String> strengths;

  final List<String> weaknesses;

  final List<String> nextConfirmations;

  const Decision({
    required this.score,
    required this.marketReadiness,
    required this.capitalProtection,
    required this.probability,
    required this.strategyAligned,
    required this.strengths,
    required this.weaknesses,
    required this.nextConfirmations,
  });
}
