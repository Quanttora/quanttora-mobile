import 'package:flutter/material.dart';

import '../common/error_card.dart';
import '../common/loading_card.dart';
import '../index_card.dart';

class MarketIndicesSection extends StatelessWidget {
  final bool loading;
  final String? error;
  final Map<String, dynamic>? data;

  const MarketIndicesSection({
    super.key,
    required this.loading,
    required this.data,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const LoadingCard(
        message: "Loading Live Market...",
      );
    }

    if (error != null) {
      return ErrorCard(message: error!);
    }

    if (data == null) {
      return const ErrorCard(
        message: "Market data unavailable",
      );
    }

    final market =
        (data!["data"] as Map<String, dynamic>?) ?? {};

    return Column(
      children: [
        _buildCard(
          market,
          "NSE_INDEX:Nifty 50",
          "NIFTY 50",
        ),
        const SizedBox(height: 16),
        _buildCard(
          market,
          "NSE_INDEX:Nifty Bank",
          "BANK NIFTY",
        ),
        const SizedBox(height: 16),
        _buildCard(
          market,
          "NSE_INDEX:India VIX",
          "INDIA VIX",
        ),
      ],
    );
  }

  Widget _buildCard(
    Map<String, dynamic> market,
    String key,
    String title,
  ) {
    final quote = market[key];

    if (quote == null || quote is! Map<String, dynamic>) {
      return IndexCard(
        name: title,
        value: "--",
        change: "--",
        positive: true,
      );
    }

    final lastPrice =
        (quote["last_price"] ?? "--").toString();

    final netChange =
        ((quote["net_change"] ?? 0) as num).toDouble();

    final previousClose =
        ((quote["ohlc"]?["close"] ?? 0) as num).toDouble();

    final percent =
        previousClose == 0
            ? 0
            : (netChange / previousClose) * 100;

    return IndexCard(
      name: title,
      value: lastPrice,
      change:
          "${netChange >= 0 ? "+" : ""}${netChange.toStringAsFixed(2)} (${percent.toStringAsFixed(2)}%)",
      positive: netChange >= 0,
    );
  }
}