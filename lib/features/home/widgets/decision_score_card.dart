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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.psychology_alt_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                "AI Decision Score",
                style: AppTextStyles.heading,
              ),
            ],
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: CircularProgressIndicator(
                            value: result.totalScore / 100,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              result.totalScore.toString(),
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "/100",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 24),

              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoTile(
                      Icons.show_chart_rounded,
                      "Market Health",
                      "87 /100",
                      Colors.green,
                    ),
                    const SizedBox(height: 14),
                    _infoTile(
                      Icons.auto_graph,
                      "Strategy Match",
                      "94%",
                      Colors.blue,
                    ),
                    const SizedBox(height: 14),
                    _infoTile(
                      Icons.security,
                      "Risk Level",
                      "LOW",
                      Colors.orange,
                    ),
                    const SizedBox(height: 14),
                    _infoTile(
                      Icons.gpp_good,
                      "Verdict",
                      result.verdictText,
                      _getVerdictColor(result.verdict),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              "AI Insight\n\n${_getRating(result.totalScore)}. Market conditions are aligned with your selected strategy. Maintain discipline and execute only if all checklist items remain valid.",
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color.withValues(alpha: .12),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        )
      ],
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
    if (score >= 90) return "Excellent trading opportunity";
    if (score >= 75) return "Good quality setup";
    if (score >= 60) return "Trade with caution";
    return "Avoid this trade";
  }
}