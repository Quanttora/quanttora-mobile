import 'package:flutter/material.dart';

class MarketHealthCard extends StatelessWidget {
  const MarketHealthCard({
    super.key,
    required this.health,
    required this.status,
    required this.trend,
    required this.momentum,
    required this.liquidity,
    required this.volatility,
  });

  final int health;
  final String status;
  final String trend;
  final String momentum;
  final String liquidity;
  final String volatility;

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "MARKET HEALTH",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: 170,
              height: 170,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: health / 100,
                    strokeWidth: 12,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$health",
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(status),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _row("Trend", trend),
            const Divider(),

            _row("Momentum", momentum),
            const Divider(),

            _row("Liquidity", liquidity),
            const Divider(),

            _row("Volatility", volatility),
          ],
        ),
      ),
    );
  }
}