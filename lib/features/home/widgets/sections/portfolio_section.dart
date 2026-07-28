import 'package:flutter/material.dart';

import '../cards/portfolio_summary_card.dart';
import '../common/error_card.dart';
import '../common/loading_card.dart';

class PortfolioSection extends StatelessWidget {
  final bool loading;
  final String? error;
  final Map<String, dynamic>? portfolio;

  const PortfolioSection({
    super.key,
    required this.loading,
    required this.portfolio,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const LoadingCard(
        message: "Loading Portfolio...",
      );
    }

    if (error != null) {
      return ErrorCard(message: error!);
    }

    if (portfolio == null) {
      return const ErrorCard(
        message: "Portfolio data unavailable",
      );
    }

    return PortfolioSummaryCard(
      availableMargin:
          ((portfolio!["availableMargin"] ?? 0) as num).toDouble(),
      usedMargin:
          ((portfolio!["usedMargin"] ?? 0) as num).toDouble(),
      broker:
          (portfolio!["broker"] ?? "Upstox").toString(),
      connected:
          (portfolio!["connected"] ?? true) as bool,
    );
  }
}