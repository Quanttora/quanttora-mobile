import 'package:flutter/material.dart';

class MarketPulseCard extends StatelessWidget {
  const MarketPulseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Row(
              children: [

                Icon(
                  Icons.public_rounded,
                  color: Color(0xFF2563EB),
                ),

                SizedBox(width: 10),

                Text(
                  "Market Pulse",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 8),

            const Text(
              "Quick overview before you enter a trade.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            const Row(
              children: [

                Expanded(
                  child: _MarketTile(
                    title: "NIFTY 50",
                    value: "+0.82%",
                    trend: "Bullish",
                    color: Colors.green,
                  ),
                ),

                SizedBox(width: 12),

                Expanded(
                  child: _MarketTile(
                    title: "BANKNIFTY",
                    value: "-0.18%",
                    trend: "Neutral",
                    color: Colors.orange,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 16),

            const Row(
              children: [

                Expanded(
                  child: _MarketTile(
                    title: "INDIA VIX",
                    value: "-2.4%",
                    trend: "Low Fear",
                    color: Colors.blue,
                  ),
                ),

                SizedBox(width: 12),

                Expanded(
                  child: _MarketTile(
                    title: "FII Activity",
                    value: "+₹860Cr",
                    trend: "Buying",
                    color: Colors.deepPurple,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [

                  Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF2563EB),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      "AI Bias: Bullish. Wait for pullback entries instead of chasing breakouts.",
                    ),
                  ),

                ],
              ),
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
  final String trend;
  final Color color;

  const _MarketTile({
    required this.title,
    required this.value,
    required this.trend,
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

          const SizedBox(height: 12),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            trend,
            style: TextStyle(
              color: color,
            ),
          ),

        ],
      ),
    );
  }
}  