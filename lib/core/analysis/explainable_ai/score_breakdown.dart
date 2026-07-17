import 'score_item.dart';

class ScoreBreakdown {
  final List<ScoreItem> items;
  final int finalScore;
  final String grade;

  const ScoreBreakdown({
    required this.items,
    required this.finalScore,
    required this.grade,
  });
}