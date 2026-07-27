import 'package:flutter/material.dart';

class BrokerStatusCard extends StatelessWidget {
  final bool connected;
  final String broker;
  final String userName;
  final String email;
  final String userId;

  final double availableMargin;
  final double usedMargin;

  final VoidCallback? onConnect;

  const BrokerStatusCard({
    super.key,
    required this.connected,
    required this.broker,
    required this.userName,
    required this.email,
    required this.userId,
    required this.availableMargin,
    required this.usedMargin,
    this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: connected
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Broker Connected",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  broker,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text("User : $userName"),
                Text("Email : $email"),
                Text("User ID : $userId"),
                const Divider(height: 30),
                Text(
                  "Available Margin",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "₹ ${availableMargin.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  "Used Margin",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "₹ ${usedMargin.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            )
          : Column(
              children: [
                const Icon(
                  Icons.account_balance,
                  size: 44,
                  color: Colors.orange,
                ),
                const SizedBox(height: 10),
                const Text(
                  "No Broker Connected",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 15),
                FilledButton(
                  onPressed: onConnect,
                  child: const Text("Connect Upstox"),
                ),
              ],
            ),
    );
  }
}