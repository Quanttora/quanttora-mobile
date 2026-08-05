import 'package:flutter/material.dart';

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                Icon(Icons.flash_on_rounded, color: Color(0xFFF59E0B)),

                SizedBox(width: 10),

                Text(
                  "Quick Actions",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: _ActionTile(
                    icon: Icons.analytics_outlined,
                    title: "Analyze",
                    color: Colors.blue,
                  ),
                ),

                SizedBox(width: 14),

                Expanded(
                  child: _ActionTile(
                    icon: Icons.play_circle_fill_rounded,
                    title: "Execute",
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _ActionTile(
                    icon: Icons.menu_book_rounded,
                    title: "Academy",
                    color: Colors.deepPurple,
                  ),
                ),

                SizedBox(width: 14),

                Expanded(
                  child: _ActionTile(
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

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _ActionTile({
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
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: color.withOpacity(.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 34),

            SizedBox(height: 10),

            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
