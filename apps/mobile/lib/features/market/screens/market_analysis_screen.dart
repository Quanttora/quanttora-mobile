import 'package:flutter/material.dart';

import '../widgets/market_health_card.dart';

class MarketAnalysisScreen extends StatelessWidget {
  const MarketAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Market Analysis",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [

          MarketHealthCard(
            health: 82,
            status: "Healthy",
            trend: "Bullish",
            momentum: "Strong",
            liquidity: "High",
            volatility: "Low",
          ),

        ],
      ),
    );
  }
}