import 'package:flutter/material.dart';

import '../../../core/decision_engine/decision_result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/quanttora_card.dart';

class DecisionScoreCard extends StatelessWidget {
  final DecisionResult result;

  const DecisionScoreCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final score = result.totalScore.clamp(0, 100);
    final verdictColor = _getVerdictColor(result.verdict);

    return QuanttoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.psychology_alt_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'AI Decision Score',
                  style: AppTextStyles.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              SizedBox(
                width: 132,
                height: 132,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 132,
                      height: 132,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 11,
                        backgroundColor: AppColors.surfaceAlt,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          score.toString(),
                          style: AppTextStyles.headlineLarge,
                        ),
                        const Text('/100', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xxl),
              Expanded(
                child: _VerdictPanel(
                  verdict: result.verdictText,
                  rating: _getRating(score),
                  color: verdictColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: verdictColor.withValues(alpha: 0.08),
              borderRadius: AppRadius.mdBorder,
              border: Border.all(color: verdictColor.withValues(alpha: 0.16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.insights_rounded, color: verdictColor, size: 21),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quanttora Assessment',
                        style: AppTextStyles.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _getAssessment(result.verdict, score),
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
    if (score >= 90) {
      return 'Excellent setup';
    }

    if (score >= 75) {
      return 'Good quality setup';
    }

    if (score >= 60) {
      return 'Caution required';
    }

    return 'Weak setup';
  }

  String _getAssessment(DecisionVerdict verdict, int score) {
    switch (verdict) {
      case DecisionVerdict.execute:
        return 'The current decision engine returned an execute verdict with a score of $score/100. Confirm your strategy and risk rules before placing any trade.';

      case DecisionVerdict.wait:
        return 'The current decision engine returned a wait verdict with a score of $score/100. Conditions do not currently justify execution.';

      case DecisionVerdict.highRisk:
        return 'The current decision engine classified this setup as high risk with a score of $score/100. Do not treat the score alone as permission to trade.';

      case DecisionVerdict.avoid:
        return 'The current decision engine returned an avoid verdict with a score of $score/100. The setup does not currently satisfy the required conditions.';
    }
  }
}

class _VerdictPanel extends StatelessWidget {
  final String verdict;
  final String rating;
  final Color color;

  const _VerdictPanel({
    required this.verdict,
    required this.rating,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Verdict', style: AppTextStyles.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          verdict,
          style: AppTextStyles.headlineSmall.copyWith(color: color),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text('Score quality', style: AppTextStyles.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(rating, style: AppTextStyles.titleSmall),
      ],
    );
  }
}
