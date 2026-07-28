import 'package:flutter/material.dart';

import '../cards/holdings_card.dart';
import '../common/error_card.dart';
import '../common/loading_card.dart';

class HoldingsSection extends StatelessWidget {
  final bool loading;
  final String? error;
  final List<dynamic>? holdings;

  const HoldingsSection({
    super.key,
    required this.loading,
    required this.holdings,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const LoadingCard(
        message: "Loading Holdings...",
      );
    }

    if (error != null) {
      return ErrorCard(message: error!);
    }

    if (holdings == null || holdings!.isEmpty) {
      return const ErrorCard(
        message: "No holdings found.",
      );
    }

    return HoldingsCard(
      holdings: holdings!,
    );
  }
}