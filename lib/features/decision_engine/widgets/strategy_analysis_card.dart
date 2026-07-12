import 'package:flutter/material.dart';

import '../../../core/decision_engine/decision_result.dart';

class StrategyAnalysisCard extends StatelessWidget {
  final DecisionResult result;

  const StrategyAnalysisCard({
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
                  Icons.auto_graph_rounded,
                  color: Color(0xFF7C3AED),
                ),

                SizedBox(width: 10),

                Text(
                  "Strategy Analysis",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                const Expanded(
                  child: Text(
                    "Strategy Score",
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                Text(
                  "${result.strategyScore} / 20",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7C3AED),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 20),

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: result.strategyScore / 20,
                minHeight: 10,
                backgroundColor: Colors.grey.shade300,
                color: const Color(0xFF7C3AED),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Engine Reasons",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ...result.reasons.skip(5).take(4).map(
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
    );
  }
}