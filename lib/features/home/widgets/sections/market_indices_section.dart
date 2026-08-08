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
      return const LoadingCard(message: "Loading Live Market...");
    }

    if (error != null) {
      return ErrorCard(message: error!);
    }

    if (data == null) {
      return const ErrorCard(message: "Market data unavailable");
    }

    final indices = (data!["indices"] as Map<String, dynamic>?) ?? {};

    return Column(
      children: [
        _card(indices["nifty"], "NIFTY 50"),
        const SizedBox(height: 16),
        _card(indices["bankNifty"], "BANK NIFTY"),
        const SizedBox(height: 16),
        _card(indices["sensex"], "SENSEX"),
        const SizedBox(height: 16),
        _card(indices["indiaVix"], "INDIA VIX"),
      ],
    );
  }

  Widget _card(dynamic quote, String title) {
    if (quote == null) {
      return IndexCard(name: title, value: "--", change: "--", positive: true);
    }

    final map = quote as Map<String, dynamic>;

    final price = (map["ltp"] ?? "--").toString();

    final change = ((map["change"] ?? 0) as num).toDouble();

    final percent = ((map["changePercent"] ?? 0) as num).toDouble();

    return IndexCard(
      name: title,
      value: price,
      change:
          "${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)} (${percent.toStringAsFixed(2)}%)",
      positive: change >= 0,
    );
  }
}
