import 'package:flutter/material.dart';

class PortfolioSummaryCard extends StatelessWidget {
  final double availableMargin;
  final double usedMargin;
  final String broker;
  final bool connected;

  const PortfolioSummaryCard({
    super.key,
    required this.availableMargin,
    required this.usedMargin,
    required this.broker,
    required this.connected,
  });

  double get totalPortfolio => availableMargin + usedMargin;

  String _money(double value) {
    return "₹${value.toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    final pnl = availableMargin - usedMargin;
    final pnlColor = pnl >= 0 ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.indigo,
                size: 30,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Portfolio Summary",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: connected
                      ? Colors.green.withValues(alpha: .12)
                      : Colors.red.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  connected ? broker.toUpperCase() : "DISCONNECTED",
                  style: TextStyle(
                    color: connected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Center(
            child: Column(
              children: [
                const Text(
                  "Portfolio Value",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  _money(totalPortfolio),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _Tile(
                  title: "Available",
                  value: _money(availableMargin),
                  color: Colors.green,
                  icon: Icons.account_balance_wallet,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _Tile(
                  title: "Used",
                  value: _money(usedMargin),
                  color: Colors.orange,
                  icon: Icons.payments,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          _Tile(
            title: "Today's P&L",
            value: _money(pnl),
            color: pnlColor,
            icon: Icons.trending_up,
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _Tile({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
