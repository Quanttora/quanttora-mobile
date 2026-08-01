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

  int get positiveScore {
    return items
        .where((item) => item.positive)
        .fold<int>(0, (total, item) => total + item.score);
  }

  int get penaltyScore {
    return items
        .where((item) => !item.positive)
        .fold<int>(0, (total, item) => total + item.score);
  }

  bool get isEmpty => items.isEmpty;

  Map<String, dynamic> toMap() {
    return {
      'finalScore': finalScore,
      'grade': grade,
      'positiveScore': positiveScore,
      'penaltyScore': penaltyScore,
      'items': items
          .map(
            (item) => {
              'title': item.title,
              'score': item.score,
              'positive': item.positive,
              'reason': item.reason,
            },
          )
          .toList(growable: false),
    };
  }

  @override
  String toString() {
    return 'ScoreBreakdown('
        'finalScore: $finalScore, '
        'grade: $grade, '
        'items: ${items.length}'
        ')';
  }
}
