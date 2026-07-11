import 'package:flutter/material.dart';

class AcademyCard extends StatelessWidget {
  const AcademyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: const [

                Icon(
                  Icons.school_rounded,
                  color: Colors.orange,
                ),

                SizedBox(width: 10),

                Text(
                  "Trading Academy",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 20),

            const _CourseTile(
              title: "Candlestick Basics",
              subtitle: "15 Lessons",
              icon: Icons.candlestick_chart,
              color: Colors.blue,
            ),

            SizedBox(height: 14),

            const _CourseTile(
              title: "Risk Management",
              subtitle: "10 Lessons",
              icon: Icons.shield_outlined,
              color: Colors.green,
            ),

            SizedBox(height: 14),

            const _CourseTile(
              title: "Options Greeks",
              subtitle: "18 Lessons",
              icon: Icons.auto_graph,
              color: Colors.deepPurple,
            ),

          ],
        ),
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _CourseTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [

          CircleAvatar(
            backgroundColor: color,
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

              ],
            ),
          ),

          const Icon(Icons.arrow_forward_ios_rounded, size: 18),

        ],
      ),
    );
  }
}