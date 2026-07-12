import 'package:flutter/material.dart';

class ScoreBar extends StatelessWidget {
  final String title;
  final int score;
  final int maxScore;
  final Color color;

  const ScoreBar({
    super.key,
    required this.title,
    required this.score,
    required this.maxScore,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = score / maxScore;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        children: [

          Row(
            children: [

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Text(
                "$score / $maxScore",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              color: color,
              backgroundColor: Colors.grey.shade300,
            ),
          ),

        ],
      ),
    );
  }
}