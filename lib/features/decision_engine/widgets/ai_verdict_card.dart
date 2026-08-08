import 'package:flutter/material.dart';

import '../../../core/decision_engine/decision_result.dart';

class AIVerdictCard extends StatelessWidget {
  final DecisionResult result;

  const AIVerdictCard({super.key, required this.result});

  Color get verdictColor {
    switch (result.verdict) {
      case DecisionVerdict.execute:
        return Colors.green;
      case DecisionVerdict.wait:
        return Colors.orange;
      case DecisionVerdict.highRisk:
        return Colors.deepOrange;
      case DecisionVerdict.avoid:
        return Colors.red;
    }
  }

  IconData get verdictIcon {
    switch (result.verdict) {
      case DecisionVerdict.execute:
        return Icons.check_circle;
      case DecisionVerdict.wait:
        return Icons.schedule;
      case DecisionVerdict.highRisk:
        return Icons.warning;
      case DecisionVerdict.avoid:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "AI VERDICT",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            Icon(verdictIcon, color: verdictColor, size: 70),

            const SizedBox(height: 16),

            Text(
              result.verdictText,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: verdictColor,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Q-Score ${result.totalScore}/100",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Reasons",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            ...result.reasons.map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: verdictColor, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(reason)),
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
