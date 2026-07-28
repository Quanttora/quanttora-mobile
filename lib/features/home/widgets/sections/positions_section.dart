import 'package:flutter/material.dart';

import '../cards/positions_card.dart';
import '../common/error_card.dart';
import '../common/loading_card.dart';

class PositionsSection extends StatelessWidget {
  final bool loading;
  final String? error;
  final List<dynamic>? positions;

  const PositionsSection({
    super.key,
    required this.loading,
    required this.positions,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const LoadingCard(
        message: "Loading Positions...",
      );
    }

    if (error != null) {
      return ErrorCard(
        message: error!,
      );
    }

    if (positions == null || positions!.isEmpty) {
      return const ErrorCard(
        message: "No open positions.",
      );
    }

    return PositionsCard(
      positions: positions!,
    );
  }
}