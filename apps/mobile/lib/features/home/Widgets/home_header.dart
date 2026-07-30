import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.userName,
  });

  final String userName;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    String greeting;

    if (now.hour < 12) {
      greeting = "Good Morning";
    } else if (now.hour < 17) {
      greeting = "Good Afternoon";
    } else {
      greeting = "Good Evening";
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: AppTextStyles.displayMedium,
                ),
                const SizedBox(height: 4),
                const Text(
                  "Welcome to Quanttora",
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}