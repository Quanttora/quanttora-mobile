import 'package:flutter/material.dart';

import '../widgets/hero_ai_card.dart';
import '../widgets/market_status_card.dart';

class PremiumHomeScreen extends StatelessWidget {
  const PremiumHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff050816),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              const Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    child: Icon(Icons.auto_graph),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Quanttora AI",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const MarketStatusCard(),

              const SizedBox(height: 24),

              const HeroAiCard(),

              const SizedBox(height: 30),

              const Text(
                "Market Overview",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: const [
                  Expanded(
                    child: _IndexCard(
                      title: "NIFTY",
                      value: "+0.82%",
                      color: Color(0xff00E676),
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _IndexCard(
                      title: "BANKNIFTY",
                      value: "+0.54%",
                      color: Color(0xff00E676),
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _IndexCard(
                      title: "SENSEX",
                      value: "-0.12%",
                      color: Color(0xffFF5252),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "Coming Next...",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "• Live Watchlist\n"
                "• AI Trade History\n"
                "• Market News\n"
                "• Market Movers\n"
                "• Quick Actions",
                style: TextStyle(
                  color: Colors.white38,
                  height: 1.8,
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _IndexCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _IndexCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff101828),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}