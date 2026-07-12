import 'package:flutter/material.dart';

class MarketAnalysisCard extends StatelessWidget {
  const MarketAnalysisCard({super.key});

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
                  Icons.show_chart_rounded,
                  color: Color(0xFF16A34A),
                ),

                SizedBox(width: 10),

                Text(
                  "Market Analysis",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 10),

            const Text(
              "Live market health before entering the trade.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            const _AnalysisTile(
              title: "Trend",
              value: "Bullish",
              score: 96,
              color: Colors.green,
            ),

            const SizedBox(height: 18),

            const _AnalysisTile(
              title: "Momentum",
              value: "Strong",
              score: 92,
              color: Colors.blue,
            ),

            const SizedBox(height: 18),

            const _AnalysisTile(
              title: "Volume",
              value: "Above Average",
              score: 89,
              color: Colors.orange,
            ),

            const SizedBox(height: 18),

            const _AnalysisTile(
              title: "Volatility",
              value: "Healthy",
              score: 84,
              color: Colors.deepPurple,
            ),

            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEFFAF3),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [

                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      "AI Analysis: Market conditions support a high probability setup.",
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                      ),
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

class _AnalysisTile extends StatelessWidget {
  final String title;
  final String value;
  final int score;
  final Color color;

  const _AnalysisTile({
    required this.title,
    required this.value,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              "$score%",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),

          ],
        ),

        const SizedBox(height: 6),

        Text(
          value,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 10),

        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 8,
            color: color,
            backgroundColor: Colors.grey.shade300,
          ),
        ),

      ],
    );
  }
}