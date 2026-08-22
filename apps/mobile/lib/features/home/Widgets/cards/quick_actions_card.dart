import 'package:flutter/material.dart';

import '../../academy/screens/academy_home_screen.dart';
import '../../../core/theme/app_card_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({
    super.key,
    this.onBrokerTap,
    this.onJournalTap,
    this.onAiTap,
    this.onWatchlistTap,
  });

  final VoidCallback? onBrokerTap;
  final VoidCallback? onJournalTap;
  final VoidCallback? onAiTap;
  final VoidCallback? onWatchlistTap;

  void _openAcademy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AcademyHomeScreen(),
      ),
    );
  }

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
            'Quick Actions',
            style: AppTextStyles.titleLarge,
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  title: 'Broker',
                  icon: Icons.account_balance_rounded,
                  color: AppColors.primary,
                  onTap: onBrokerTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  title: 'Journal',
                  icon: Icons.menu_book_rounded,
                  color: Colors.deepPurple,
                  onTap: onJournalTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  title: 'AI',
                  icon: Icons.auto_awesome_rounded,
                  color: Colors.deepPurpleAccent,
                  onTap: onAiTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  title: 'Watchlist',
                  icon: Icons.visibility_rounded,
                  color: Colors.orange,
                  onTap: onWatchlistTap,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _AcademyButton(
            onTap: () => _openAcademy(context),
          ),
        ],
      ),
    );
  }
}

class _AcademyButton extends StatelessWidget {
  const _AcademyButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.deepPurple.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 18,
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trading Academy',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Learn trading step by step',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
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
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 22,
            horizontal: 16,
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: AppTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}