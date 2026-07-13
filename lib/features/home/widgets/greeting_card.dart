import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/quanttora_card.dart';

class GreetingCard extends StatelessWidget {
  const GreetingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return QuanttoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Good Morning 👋",
            style: AppTextStyles.bodySmall,
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            "Sagar",
            style: AppTextStyles.display,
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            "Trade with discipline.\nProfit is a by-product.",
            style: AppTextStyles.body,
          ),

          const SizedBox(height: AppSpacing.lg),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.psychology_alt_rounded,
                  color: AppColors.primary,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    "Today's AI Focus: Wait for high-quality setups. Don't chase the market.",
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}