import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class ConfidenceGauge extends StatelessWidget {
  final int score;

  const ConfidenceGauge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final progress = score / 100;

    Color color;

    if (score >= 80) {
      color = AppColors.success;
    } else if (score >= 60) {
      color = AppColors.warning;
    } else {
      color = AppColors.danger;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 170,
          height: 170,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 12,
            color: color,
            backgroundColor: Colors.grey.shade300,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$score",
              style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
            ),
            const Text("AI Score"),
          ],
        ),
      ],
    );
  }
}
