import 'package:flutter/material.dart';

import '../../../core/theme/app_card_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class MarketNewsCard extends StatelessWidget {
  const MarketNewsCard({
    super.key,
    required this.news,
    this.onNewsTap,
  });

  final List<MarketNews> news;
  final ValueChanged<MarketNews>? onNewsTap;

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
            "Market News",
            style: AppTextStyles.titleLarge,
          ),

          const SizedBox(height: 20),

          if (news.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  "No market news available",
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            )
          else
            ...List.generate(
              news.length,
              (index) {
                final item = news[index];

                return Column(
                  children: [
                    _NewsTile(
                      news: item,
                      onTap: () => onNewsTap?.call(item),
                    ),
                    if (index != news.length - 1)
                      const Divider(height: 24),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _NewsTile extends StatelessWidget {
  const _NewsTile({
    required this.news,
    required this.onTap,
  });

  final MarketNews news;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final badgeColor = news.isHighImpact
        ? AppColors.danger
        : AppColors.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              news.isHighImpact
                  ? Icons.campaign_rounded
                  : Icons.article_rounded,
              color: badgeColor,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: AppTextStyles.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    news.source,
                    style: AppTextStyles.bodySmall,
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Text(
                        news.time,
                        style: AppTextStyles.bodySmall,
                      ),

                      if (news.isHighImpact) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            "HIGH IMPACT",
                            style: TextStyle(
                              color: AppColors.danger,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class MarketNews {
  const MarketNews({
    required this.title,
    required this.source,
    required this.time,
    required this.isHighImpact,
  });

  final String title;
  final String source;
  final String time;
  final bool isHighImpact;
}