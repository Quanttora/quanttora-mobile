import 'package:flutter/material.dart';

import '../../../core/analysis/analysis_engine.dart';

class AIDecisionScreen extends StatelessWidget {
  final String market;
  final String direction;

  const AIDecisionScreen({
    super.key,
    required this.market,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    final result = AnalysisEngine.analyze(
      market: market,
      direction: direction,
    );

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        title: const Text("AI Decision Report"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          Center(
            child: Column(
              children: [

                const Text(
                  "AI CONFIDENCE",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "${result.confidence}%",
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),

              ],
            ),
          ),

          const SizedBox(height: 30),

          tile("Market", result.market),
          tile("Direction", result.direction),
          tile("Market Health", "${result.marketHealth}/100"),
          tile("Trend", result.trend),
          tile("Momentum", result.momentum),
          tile("Volume", result.volume),
          tile("Liquidity", result.liquidity),
          tile("Volatility", result.volatility),
          tile("Sector Strength", result.sectorStrength),
          tile("Heat Map", result.heatMap),
          tile("Risk", result.risk),

          const SizedBox(height: 25),

          const Text(
            "AI Reasons",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          ...result.reasons.map(
            (e) => Card(
              child: ListTile(
                leading: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                title: Text(e),
              ),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text(
                "PROCEED TO BROKER",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget tile(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}