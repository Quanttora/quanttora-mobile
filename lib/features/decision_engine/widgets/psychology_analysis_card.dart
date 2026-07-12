import 'package:flutter/material.dart';

class PsychologyAnalysisCard extends StatelessWidget {
  const PsychologyAnalysisCard({super.key});

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
                  Icons.psychology_rounded,
                  color: Color(0xFF7C3AED),
                ),

                SizedBox(width: 10),

                Text(
                  "Psychology Analysis",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 10),

            const Text(
              "AI evaluates your current trading mindset.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            const _PsychologyRow(
              title: "Emotional State",
              value: "Calm",
              color: Colors.green,
            ),

            const Divider(),

            const _PsychologyRow(
              title: "Today's Trades",
              value: "1 / 3",
              color: Colors.blue,
            ),

            const Divider(),

            const _PsychologyRow(
              title: "Revenge Trading",
              value: "No",
              color: Colors.green,
            ),

            const Divider(),

            const _PsychologyRow(
              title: "Discipline Score",
              value: "94%",
              color: Colors.deepPurple,
            ),

            const Divider(),

            const _PsychologyRow(
              title: "Confidence",
              value: "Healthy",
              color: Colors.orange,
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Icon(
                    Icons.lightbulb,
                    color: Color(0xFF7C3AED),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      "AI Coach:\nYou are following your trading rules today. Stay patient and don't increase position size after a winning trade.",
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

class _PsychologyRow extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _PsychologyRow({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [

          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),

        ],
      ),
    );
  }
}