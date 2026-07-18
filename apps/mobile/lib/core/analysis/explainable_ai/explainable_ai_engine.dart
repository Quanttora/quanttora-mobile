import 'score_breakdown.dart';
import 'score_item.dart';

class ExplainableAIEngine {

  static ScoreBreakdown generate({

    required int trend,

    required int ema,

    required int volume,

    required int adx,

    required int optionChain,

    required int heatMap,

    required int riskPenalty,

    required int globalPenalty,

  }) {

    final items = [

      ScoreItem(
        title: "Trend Alignment",
        score: trend,
        positive: true,
        reason: "Trend supports your direction.",
      ),

      ScoreItem(
        title: "EMA Alignment",
        score: ema,
        positive: true,
        reason: "EMA 22 and EMA 33 are aligned.",
      ),

      ScoreItem(
        title: "Volume",
        score: volume,
        positive: true,
        reason: "Healthy market participation.",
      ),

      ScoreItem(
        title: "ADX",
        score: adx,
        positive: true,
        reason: "Trending market detected.",
      ),

      ScoreItem(
        title: "Option Chain",
        score: optionChain,
        positive: true,
        reason: "Option data supports the setup.",
      ),

      ScoreItem(
        title: "Heat Map",
        score: heatMap,
        positive: true,
        reason: "Market breadth is supportive.",
      ),

      ScoreItem(
        title: "Global Risk",
        score: globalPenalty,
        positive: false,
        reason: "Global conditions reduced confidence.",
      ),

      ScoreItem(
        title: "Risk Engine",
        score: riskPenalty,
        positive: false,
        reason: "Risk controls reduced confidence.",
      ),
    ];

    int total = 0;

    for (final item in items) {
      total += item.positive ? item.score : -item.score;
    }

    total = total.clamp(0, 100);

    String grade = "D";

    if (total >= 95) {
      grade = "A+";
    } else if (total >= 90) {
      grade = "A";
    } else if (total >= 80) {
      grade = "B";
    } else if (total >= 70) {
      grade = "C";
    }

    return ScoreBreakdown(
      items: items,
      finalScore: total,
      grade: grade,
    );
  }
}