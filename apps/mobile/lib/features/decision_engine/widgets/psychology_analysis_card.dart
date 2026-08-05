import 'package:flutter/material.dart';

import '../../../core/decision_engine/decision_result.dart';

class PsychologyAnalysisCard extends StatelessWidget {
  final DecisionResult result;

  const PsychologyAnalysisCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology_rounded, color: Color(0xFF7C3AED)),

                SizedBox(width: 10),

                Text(
                  "Psychology Analysis",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Psychology Score",
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                Text(
                  "${result.psychologyScore} / 15",
                  style: const TextStyle(
                    color: Color(0xFF7C3AED),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: result.psychologyScore / 15,
                minHeight: 10,
                backgroundColor: Colors.grey.shade300,
                color: const Color(0xFF7C3AED),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(Icons.psychology_alt, color: Color(0xFF7C3AED)),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      "Psychology score is now calculated by the Quanttora Decision Engine.",
                      style: TextStyle(height: 1.5),
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
