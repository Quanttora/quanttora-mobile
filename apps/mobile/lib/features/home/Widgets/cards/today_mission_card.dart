import 'package:flutter/material.dart';

class TodayMissionCard extends StatelessWidget {
  const TodayMissionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.flag_circle_rounded, color: Color(0xFF2563EB)),

                SizedBox(width: 10),

                Text(
                  "Today's Mission",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const Text(
              "Complete these before ending today's session.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 22),

            const _MissionTile(
              title: "Wait for confirmation candle",
              completed: true,
            ),

            const SizedBox(height: 12),

            const _MissionTile(title: "Maximum 3 trades", completed: true),

            const SizedBox(height: 12),

            const _MissionTile(
              title: "Risk Reward above 1 : 2",
              completed: false,
            ),

            const SizedBox(height: 12),

            const _MissionTile(
              title: "Avoid revenge trading",
              completed: false,
            ),

            const SizedBox(height: 24),

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const LinearProgressIndicator(
                value: .50,
                minHeight: 10,
                backgroundColor: Color(0xFFE5E7EB),
                color: Color(0xFF2563EB),
              ),
            ),

            const SizedBox(height: 10),

            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                "2 / 4 Completed",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionTile extends StatelessWidget {
  final String title;
  final bool completed;

  const _MissionTile({required this.title, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: completed ? Colors.green : Colors.grey,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              decoration: completed
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}
