import 'package:flutter/material.dart';

import '../cards/ai_coach_card.dart';
import '../common/error_card.dart';
import '../common/loading_card.dart';

class AiSection extends StatelessWidget {
  final bool loading;
  final String? error;
  final Map<String, dynamic>? aiData;

  const AiSection({
    super.key,
    required this.loading,
    required this.aiData,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const LoadingCard(message: "Analyzing Market...");
    }

    if (error != null) {
      return ErrorCard(message: error!);
    }

    if (aiData == null) {
      return const ErrorCard(message: "AI analysis unavailable");
    }

    return const AICoachCard();
  }
}
