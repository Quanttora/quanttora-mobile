import 'package:flutter/material.dart';

class MarketPulseCard extends StatelessWidget {
  const MarketPulseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Row(
              children: [
                Icon(Icons.show_chart, color: Colors.green),
                SizedBox(width: 10),
                Text(
                  "Market Pulse",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                Expanded(
                  child: _MarketTile(
                    title: "NIFTY 50",
                    value: "+0.82%",
                    color: Colors.green,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _MarketTile(
                    title: "BANKNIFTY",
                    value: "-0.18%",
                    color: Colors.red,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 16),

            const Text(
              "AI View",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Market sentiment is Bullish. Avoid chasing breakout candles. Wait for confirmation near support.",
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketTile extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MarketTile({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [

          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}