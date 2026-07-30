import 'package:flutter/material.dart';

import '../../../core/theme/app_card_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class PortfolioSummaryCard extends StatelessWidget {
  const PortfolioSummaryCard({
    super.key,
    required this.totalValue,
    required this.todayPnL,
    required this.todayPnLPercent,
    required this.isProfit,
  });

  final String totalValue;
  final String todayPnL;
  final String todayPnLPercent;
  final bool isProfit;

  @override
  Widget build(BuildContext context) {
    final pnlColor = isProfit
        ? AppColors.profit
        : AppColors.loss;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      padding: const EdgeInsets.all(
        AppSpacing.cardPadding,
      ),
      decoration: AppCardTheme.highlightedCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Portfolio Value",
            style: AppTextStyles.bodyMedium,
          ),

          const SizedBox(height: 8),

          Text(
            totalValue,
            style: AppTextStyles.portfolioValue,
          ),

          const SizedBox(height: 20),

          Row(
            children: [

              Icon(
                isProfit
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: pnlColor,
                size: 22,
              ),

              const SizedBox(width: 8),

              Text(
                todayPnL,
                style: isProfit
                    ? AppTextStyles.pnlProfit
                    : AppTextStyles.pnlLoss,
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: pnlColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  todayPnLPercent,
                  style: TextStyle(
                    color: pnlColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}