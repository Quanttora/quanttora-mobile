import 'package:flutter/material.dart';

import '../../../core/theme/app_card_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class MarketNewsCard extends StatelessWidget {
  const MarketNewsCard({
    super.key,
    required this.news,
  });

  final List<MarketNews> news;

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
                  "Market News",
                  style: AppTextStyles.titleLarge,
                ),
              ),

              TextButton(
                onPressed: () {},
                child: const Text("View All"),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...List.generate(
            news.length,
            (index) => _NewsTile(
              news: news[index],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsTile extends StatelessWidget {
  const _NewsTile({
    required this.news,
  });

  final MarketNews news;

  @override
  Widget build(BuildContext context) {
    final Color color = news.isHighImpact
        ? AppColors.danger
        : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              news.isHighImpact
                  ? Icons.campaign_rounded
                  : Icons.article_rounded,
              color: color,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news.title,
                  style: AppTextStyles.titleMedium,
                ),

                const SizedBox(height: 8),
                                Row(
                  children: [
                    Text(
                      news.source,
                      style: AppTextStyles.bodySmall,
                    ),

                    const SizedBox(width: 10),

                    Text(
                      "•",
                      style: AppTextStyles.bodySmall,
                    ),

                    const SizedBox(width: 10),

                    Text(
                      news.time,
                      style: AppTextStyles.bodySmall,
                    ),

                    if (news.isHighImpact) ...[
                      const SizedBox(width: 12),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "HIGH IMPACT",
                          style: TextStyle(
                            color: AppColors.danger,
                            fontSize: 11,
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

          const SizedBox(width: 12),

          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.grey.shade500,
          ),
        ],
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