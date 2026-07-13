import 'package:flutter/material.dart';

import '../../../core/decision_engine/decision_result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/quanttora_card.dart';

class DecisionScoreCard extends StatelessWidget {
  final DecisionResult result;

  const DecisionScoreCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return QuanttoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Q-SCORE™",
            style: AppTextStyles.heading,
          ),

          const SizedBox(height: AppSpacing.lg),

          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 8,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    result.totalScore.toString(),
                    style: AppTextStyles.score,
                  ),
                  Text(
                    "/100",
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            result.verdictText,
            style: AppTextStyles.verdict(
              color: _getVerdictColor(result.verdict),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            _getRating(result.totalScore),
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }

  Color _getVerdictColor(DecisionVerdict verdict) {
    switch (verdict) {
      case DecisionVerdict.execute:
        return AppColors.success;
      case DecisionVerdict.wait:
        return AppColors.warning;
      case DecisionVerdict.highRisk:
        return Colors.deepOrange;
      case DecisionVerdict.avoid:
        return AppColors.danger;
    }
  }

  String _getRating(int score) {
    if (score >= 90) return "Excellent Setup";
    if (score >= 75) return "Good Setup";
    if (score >= 60) return "Risky Setup";
    return "Avoid Trading";
  }
}