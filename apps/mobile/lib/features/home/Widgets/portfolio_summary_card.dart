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
    final pnlColor =
        isProfit ? AppColors.success : AppColors.danger;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      padding: const EdgeInsets.all(22),
      decoration: AppCardTheme.primaryCard,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Portfolio",
                      style: AppTextStyles.bodyMedium,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      totalValue,
                      style: AppTextStyles.displayMedium,
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: pnlColor.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  todayPnLPercent,
                  style: TextStyle(
                    color: pnlColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
                    Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's P&L",
                      style: AppTextStyles.bodySmall,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      todayPnL,
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: pnlColor,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: const [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 6),
                    Text(
                      "AI 84%",
                      style: AppTextStyles.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Divider(),

          const SizedBox(height: 18),
                    Row(
            children: const [
              Expanded(
                child: _StatItem(
                  title: "Win Rate",
                  value: "78%",
                ),
              ),

              Expanded(
                child: _StatItem(
                  title: "Trades",
                  value: "124",
                ),
              ),

              Expanded(
                child: _StatItem(
                  title: "Accuracy",
                  value: "91%",
                ),
              ),

              Expanded(
                child: _StatItem(
                  title: "Risk",
                  value: "Low",
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _StatusChip(
                text: "Market Open",
                color: AppColors.success,
              ),
              _StatusChip(
                text: "Risk Low",
                color: AppColors.warning,
              ),
              _StatusChip(
                text: "AI Active",
                color: AppColors.primary,
              ),
            ],
          ),
                  ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}