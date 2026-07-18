import 'package:flutter/material.dart';

import '../../../core/decision_engine/decision_result.dart';

class MarketAnalysisCard extends StatelessWidget {
  final DecisionResult result;

  const MarketAnalysisCard({
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
                  Icons.show_chart_rounded,
                  color: Color(0xFF16A34A),
                ),

                SizedBox(width: 10),

                Text(
                  "Market Analysis",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _ScoreRow(
              "Market Trend",
              result.marketScore,
              25,
            ),

            const SizedBox(height: 16),

            _ScoreRow(
              "Momentum",
              result.momentumScore,
              20,
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEFFAF3),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Engine Reasons",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...result.reasons.take(5).map(
                    (reason) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [

                          const Icon(
                            Icons.check_circle,
                            size: 18,
                            color: Colors.green,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(reason),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String title;
  final int score;
  final int maxScore;

  const _ScoreRow(
    this.title,
    this.score,
    this.maxScore,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),

        Text(
          "$score / $maxScore",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
          ),
        ),

      ],
    );
  }
}