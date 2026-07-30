import 'package:flutter/material.dart';

import '../../../core/theme/app_card_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class AITradeScoreCard extends StatelessWidget {
  const AITradeScoreCard({
    super.key,
    required this.score,
  });

  final int score;

  @override
  Widget build(BuildContext context) {
    final progress = (score / 100).clamp(0.0, 1.0);

    Color scoreColor;

    if (score >= 80) {
      scoreColor = AppColors.success;
    } else if (score >= 60) {
      scoreColor = AppColors.warning;
    } else {
      scoreColor = AppColors.danger;
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      padding: const EdgeInsets.all(
        AppSpacing.cardPadding,
      ),
      decoration: AppCardTheme.primaryCard,
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: AppColors.divider,
                  valueColor:
                      AlwaysStoppedAnimation(scoreColor),
                ),
                Text(
                  "$score",
                  style: AppTextStyles.titleLarge,
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  "AI Trade Readiness",
                  style: AppTextStyles.titleLarge,
                ),

                const SizedBox(height: 6),

                const Text(
                  "Based on market trend, volatility and risk analysis.",
                  style: AppTextStyles.bodyMedium,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    _statusChip(
                      "Trend",
                      AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    _statusChip(
                      "Risk",
                      AppColors.warning,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(
    String title,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}