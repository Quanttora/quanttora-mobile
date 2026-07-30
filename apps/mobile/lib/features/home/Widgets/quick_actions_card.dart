import 'package:flutter/material.dart';

import '../../../core/theme/app_card_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({
    super.key,
    this.onBrokerTap,
    this.onJournalTap,
    this.onAiScannerTap,
    this.onWatchlistTap,
  });

  final VoidCallback? onBrokerTap;
  final VoidCallback? onJournalTap;
  final VoidCallback? onAiScannerTap;
  final VoidCallback? onWatchlistTap;

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
            "Quick Actions",
            style: AppTextStyles.titleLarge,
          ),

          const SizedBox(height: 20),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.6,
            children: [
              _ActionTile(
                title: "Connect Broker",
                icon: Icons.account_balance_rounded,
                color: AppColors.primary,
                onTap: onBrokerTap,
              ),
              _ActionTile(
                title: "Trading Journal",
                icon: Icons.menu_book_rounded,
                color: AppColors.secondary,
                onTap: onJournalTap,
              ),
              _ActionTile(
                title: "AI Scanner",
                icon: Icons.auto_awesome_rounded,
                color: AppColors.ai,
                onTap: onAiScannerTap,
              ),
              _ActionTile(
                title: "Watchlist",
                icon: Icons.visibility_rounded,
                color: AppColors.warning,
                onTap: onWatchlistTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleMedium,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}