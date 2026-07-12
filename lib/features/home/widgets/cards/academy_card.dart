import 'package:flutter/material.dart';

class AcademyCard extends StatelessWidget {
  const AcademyCard({super.key});

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
                  Icons.school_rounded,
                  color: Color(0xFFF59E0B),
                ),

                SizedBox(width: 10),

                Text(
                  "Trading Academy",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 10),

            const Text(
              "Master trading step by step.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 22),

            const _CourseTile(
              icon: Icons.candlestick_chart,
              title: "Candlestick Mastery",
              lessons: "18 Lessons",
              progress: 0.80,
              color: Colors.blue,
            ),

            SizedBox(height: 16),

            const _CourseTile(
              icon: Icons.show_chart,
              title: "Market Structure",
              lessons: "12 Lessons",
              progress: 0.35,
              color: Colors.green,
            ),

            SizedBox(height: 16),

            const _CourseTile(
              icon: Icons.auto_graph,
              title: "Options Greeks",
              lessons: "15 Lessons",
              progress: 0.10,
              color: Colors.deepPurple,
            ),

          ],
        ),
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {

  final IconData icon;
  final String title;
  final String lessons;
  final double progress;
  final Color color;

  const _CourseTile({
    required this.icon,
    required this.title,
    required this.lessons,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [

          Row(
            children: [

              CircleAvatar(
                backgroundColor: color,
                child: Icon(
                  icon,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 14),

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

                    Text(
                      lessons,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                  ],
                ),
              ),

            ],
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: color,
              backgroundColor: Colors.grey.shade300,
            ),
          ),

        ],
      ),
    );
  }
}