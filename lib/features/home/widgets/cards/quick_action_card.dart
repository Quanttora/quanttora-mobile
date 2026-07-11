import 'package:flutter/material.dart';

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Row(
              children: [

                Icon(
                  Icons.flash_on_rounded,
                  color: Colors.amber,
                ),

                SizedBox(width: 10),

                Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: const [

                Expanded(
                  child: _ActionButton(
                    icon: Icons.analytics_outlined,
                    title: "Analyze",
                    color: Colors.blue,
                  ),
                ),

                SizedBox(width: 12),

                Expanded(
                  child: _ActionButton(
                    icon: Icons.play_circle_fill_rounded,
                    title: "Execute",
                    color: Colors.green,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: const [

                Expanded(
                  child: _ActionButton(
                    icon: Icons.menu_book_rounded,
                    title: "Academy",
                    color: Colors.deepPurple,
                  ),
                ),

                SizedBox(width: 12),

                Expanded(
                  child: _ActionButton(
                    icon: Icons.history_rounded,
                    title: "History",
                    color: Colors.orange,
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [

            Icon(
              icon,
              color: color,
              size: 30,
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

          ],
        ),
      ),
    );
  }
}