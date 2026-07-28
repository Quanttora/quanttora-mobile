import 'package:flutter/material.dart';

import 'package:mobile/features/broker/widgets/broker_status_card.dart';

class BrokerSection extends StatelessWidget {
  final bool loading;
  final bool connected;

  final String broker;
  final String userName;
  final String email;
  final String userId;

  final double availableMargin;
  final double usedMargin;

  final VoidCallback onConnect;

  const BrokerSection({
    super.key,
    required this.loading,
    required this.connected,
    required this.broker,
    required this.userName,
    required this.email,
    required this.userId,
    required this.availableMargin,
    required this.usedMargin,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return BrokerStatusCard(
      connected: connected,
      broker: broker,
      userName: userName,
      email: email,
      userId: userId,
      availableMargin: availableMargin,
      usedMargin: usedMargin,
      onConnect: onConnect,
    );
  }
}