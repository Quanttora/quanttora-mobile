import '../analysis/explainable_ai/score_breakdown.dart';

class AnalysisSession {
  final String sessionId;

  final DateTime createdAt;

  final String market;

  final String direction;

  final int confidence;

  final String grade;

  final ScoreBreakdown breakdown;

  final bool tradeExecuted;

  final bool tradeClosed;

  final double pnl;

  const AnalysisSession({
    required this.sessionId,
    required this.createdAt,
    required this.market,
    required this.direction,
    required this.confidence,
    required this.grade,
    required this.breakdown,
    required this.tradeExecuted,
    required this.tradeClosed,
    required this.pnl,
  });
}