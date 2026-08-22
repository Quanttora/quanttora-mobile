import 'package:flutter/material.dart';

import '../../../academy/screens/academy_home_screen.dart';

class AcademyCard extends StatelessWidget {
  const AcademyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AcademyHomeScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.school_rounded, color: Color(0xFFF59E0B)),
                  SizedBox(width: 10),
                  Text(
                    'Trading Academy',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Master trading step by step.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 22),
              _CourseTile(
                icon: Icons.candlestick_chart_rounded,
                title: 'Candlesticks',
                lessons: '3 Lessons',
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _CourseTile(
                icon: Icons.bar_chart_rounded,
                title: 'Volume',
                lessons: '2 Lessons',
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              _CourseTile(
                icon: Icons.analytics_rounded,
                title: 'Indicators',
                lessons: '5 Lessons',
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Open Trading Academy →',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String lessons;
  final Color color;

  const _CourseTile({
    required this.icon,
    required this.title,
    required this.lessons,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
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
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  lessons,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}
