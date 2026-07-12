import 'package:flutter/material.dart';

class AICoachCard extends StatelessWidget {
  const AICoachCard({super.key});

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
                  Icons.psychology_alt_rounded,
                  color: Color(0xFF7C3AED),
                ),

                SizedBox(width: 10),

                Text(
                  "AI Coach",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 10),

            const Text(
              "Personal guidance based on your trading behaviour.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                "💡 You usually make better entries after waiting for confirmation. Avoid impulsive breakout entries today.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Row(
              children: [

                Expanded(
                  child: _StatCard(
                    title: "Discipline",
                    value: "95%",
                    color: Colors.green,
                  ),
                ),

                SizedBox(width: 12),

                Expanded(
                  child: _StatCard(
                    title: "Patience",
                    value: "88%",
                    color: Colors.orange,
                  ),
                ),

                SizedBox(width: 12),

                Expanded(
                  child: _StatCard(
                    title: "Execution",
                    value: "92%",
                    color: Colors.blue,
                  ),
                ),

              ],
            ),

          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [

          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
            ),
          ),

        ],
      ),
    );
  }
}