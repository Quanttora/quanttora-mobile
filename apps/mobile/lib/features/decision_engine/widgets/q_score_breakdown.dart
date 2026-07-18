import 'package:flutter/material.dart';

import '../../../core/decision_engine/decision_result.dart';
import 'score_bar.dart';

class QScoreBreakdown extends StatelessWidget {
  final DecisionResult result;

  const QScoreBreakdown({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Row(
              children: [

                Icon(
                  Icons.analytics_rounded,
                  color: Color(0xFF2563EB),
                ),

                SizedBox(width: 10),

                Text(
                  "Q-Score™ Breakdown",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 25),

            ScoreBar(
              title: "Market",
              score: result.marketScore,
              maxScore: 25,
              color: Colors.green,
            ),

            ScoreBar(
              title: "Momentum",
              score: result.momentumScore,
              maxScore: 20,
              color: Colors.blue,
            ),

            ScoreBar(
              title: "Risk",
              score: result.riskScore,
              maxScore: 20,
              color: Colors.orange,
            ),

            ScoreBar(
              title: "Strategy",
              score: result.strategyScore,
              maxScore: 20,
              color: Colors.deepPurple,
            ),

            ScoreBar(
              title: "Mindset",
              score: result.psychologyScore,
              maxScore: 15,
              color: Colors.red,
            ),

            const Divider(height: 35),

            Row(
              children: [

                const Expanded(
                  child: Text(
                    "Overall Rating",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Text(
                  result.totalScore >= 90
                      ? "★★★★★"
                      : result.totalScore >= 75
                          ? "★★★★☆"
                          : result.totalScore >= 60
                              ? "★★★☆☆"
                              : "★★☆☆☆",
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.amber,
                  ),
                ),

              ],
            ),

          ],
        ),
      ),
    );
  }
}