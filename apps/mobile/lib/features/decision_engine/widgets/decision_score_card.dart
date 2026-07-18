import 'package:flutter/material.dart';

import '../../../core/decision_engine/decision_result.dart';

class DecisionScoreCard extends StatelessWidget {
  final DecisionResult result;

  const DecisionScoreCard({
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
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            const Row(
              children: [

                Icon(
                  Icons.psychology_alt_rounded,
                  color: Color(0xFF2563EB),
                  size: 30,
                ),

                SizedBox(width: 10),

                Text(
                  "Q-Score™",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 30),

            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2563EB),
                  width: 10,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Text(
                      result.totalScore.toString(),
                      style: const TextStyle(
                        fontSize: 58,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Text(
                      "/100",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.grey,
                      ),
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F1FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [

                  const Text(
                    "AI Verdict",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    result.verdictText,
                    style: const TextStyle(
                      fontSize: 28,
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
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