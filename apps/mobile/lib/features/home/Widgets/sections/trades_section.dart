import 'package:flutter/material.dart';

import '../cards/trades_card.dart';
import '../common/error_card.dart';
import '../common/loading_card.dart';

class TradesSection extends StatelessWidget {
  final bool loading;
  final String? error;
  final List<dynamic>? trades;

  const TradesSection({
    super.key,
    required this.loading,
    required this.trades,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const LoadingCard(
        message: "Loading Trades...",
      );
    }

    if (error != null) {
      return ErrorCard(
        message: error!,
      );
    }

    if (trades == null || trades!.isEmpty) {
      return const ErrorCard(
        message: "No trades available.",
      );
    }

    return TradesCard(
      trades: trades!,
    );
  }
}