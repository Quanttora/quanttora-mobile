import 'package:flutter/material.dart';

import '../cards/orders_card.dart';
import '../common/error_card.dart';
import '../common/loading_card.dart';

class OrdersSection extends StatelessWidget {
  final bool loading;
  final String? error;
  final List<dynamic>? orders;

  const OrdersSection({
    super.key,
    required this.loading,
    required this.orders,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const LoadingCard(message: "Loading Orders...");
    }

    if (error != null) {
      return ErrorCard(message: error!);
    }

    if (orders == null || orders!.isEmpty) {
      return const ErrorCard(message: "No orders available.");
    }

    return OrdersCard(orders: orders!);
  }
}
