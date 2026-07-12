import 'package:flutter/material.dart';

class StrategyAnalysisCard extends StatelessWidget {
  const StrategyAnalysisCard({super.key});

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
                  Icons.auto_graph_rounded,
                  color: Color(0xFF7C3AED),
                ),

                SizedBox(width: 10),

                Text(
                  "Strategy Analysis",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 10),

            const Text(
              "AI verifies your strategy before allowing execution.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            const _CheckTile(
              title: "Trend Alignment",
              status: true,
            ),

            const Divider(),

            const _CheckTile(
              title: "EMA Alignment",
              status: true,
            ),

            const Divider(),

            const _CheckTile(
              title: "Liquidity Sweep",
              status: true,
            ),

            const Divider(),

            const _CheckTile(
              title: "Breakout Confirmation",
              status: true,
            ),

            const Divider(),

            const _CheckTile(
              title: "Retest Confirmation",
              status: false,
            ),

            const Divider(),

            const _CheckTile(
              title: "Volume Confirmation",
              status: true,
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F8FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Icon(
                    Icons.psychology_alt,
                    color: Color(0xFF2563EB),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      "AI Opinion:\nThe setup is technically strong. Waiting for a clean retest would further improve the probability of success.",
                      style: TextStyle(
                        height: 1.5,
                        fontSize: 15,
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

class _CheckTile extends StatelessWidget {
  final String title;
  final bool status;

  const _CheckTile({
    required this.title,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [

          Icon(
            status ? Icons.check_circle : Icons.cancel,
            color: status ? Colors.green : Colors.red,
            size: 24,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),

          Text(
            status ? "PASS" : "WAIT",
            style: TextStyle(
              color: status ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),

        ],
      ),
    );
  }
}