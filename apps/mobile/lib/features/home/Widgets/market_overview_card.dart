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
          const Text(
            "Market Overview",
            style: AppTextStyles.titleLarge,
          ),

          const SizedBox(height: 20),

          _MarketTile(index: nifty),

          const Divider(),

          _MarketTile(index: sensex),

          const Divider(),

          _MarketTile(index: bankNifty),
        ],
      ),
    );
  }
}

class _MarketTile extends StatelessWidget {
  const _MarketTile({
    required this.index,
  });

  final MarketIndex index;

  @override
  Widget build(BuildContext context) {
    final color =
        index.change >= 0 ? AppColors.profit : AppColors.loss;

    final icon = index.change >= 0
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
          ),

          const SizedBox(width: 12),

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
                style: AppTextStyles.marketPrice,
              ),
              Text(
                "${index.change >= 0 ? "+" : ""}${index.changeText}",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
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