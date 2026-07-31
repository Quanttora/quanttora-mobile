import 'package:flutter/material.dart';

import '../../../core/theme/app_card_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class MarketOverviewCard extends StatelessWidget {
  const MarketOverviewCard({
    super.key,
    required this.nifty,
    required this.sensex,
    required this.bankNifty,
  });

  final MarketIndex nifty;
  final MarketIndex sensex;
  final MarketIndex bankNifty;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      padding: const EdgeInsets.all(
        AppSpacing.cardPadding,
      ),
      decoration: AppCardTheme.primaryCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Market Overview",
                  style: AppTextStyles.titleLarge,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "LIVE",
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _MarketRow(index: nifty),

          const Divider(height: 28),

          _MarketRow(index: sensex),

          const Divider(height: 28),

          _MarketRow(index: bankNifty),

          const SizedBox(height: 18),
                    Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .05),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.insights_rounded,
                  color: AppColors.primary,
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Text(
                    "Market sentiment remains positive. Banking continues to lead the rally.",
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

class _MarketRow extends StatelessWidget {
  const _MarketRow({
    required this.index,
  });

  final MarketIndex index;

  @override
  Widget build(BuildContext context) {
    final bool positive = index.change >= 0;
    final Color color =
        positive ? AppColors.success : AppColors.danger;

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            positive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: color,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Text(
            index.name,
            style: AppTextStyles.titleMedium,
          ),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              index.value,
              style: AppTextStyles.titleLarge,
            ),

            const SizedBox(height: 4),
                        Text(
              index.changeText,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class MarketIndex {
  const MarketIndex({
    required this.name,
    required this.value,
    required this.change,
    required this.changeText,
  });

  final String name;
  final String value;
  final double change;
  final String changeText;
}