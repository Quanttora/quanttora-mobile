import 'package:flutter/material.dart';

class AITradeScoreCard extends StatelessWidget {
  const AITradeScoreCard({
    super.key,
    required this.score,
  });

  final int score;

  @override
  Widget build(BuildContext context) {
    // AI score is now displayed inside Portfolio Hero Card.
    // Keeping this widget prevents breaking existing code.
    return const SizedBox.shrink();
  }
}