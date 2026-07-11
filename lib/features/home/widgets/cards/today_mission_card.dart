import 'package:flutter/material.dart';

class TodayMissionCard extends StatelessWidget {
  const TodayMissionCard({super.key});

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
                  Icons.flag_circle,
                  color: Color(0xFF2563EB),
                ),

                SizedBox(width: 10),

                Text(
                  "Today's Mission",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            _MissionItem("Wait for confirmation candle"),

            SizedBox(height: 12),

            _MissionItem("Maximum 3 trades"),

            SizedBox(height: 12),

            _MissionItem("Risk Reward above 1:2"),

            SizedBox(height: 12),

            _MissionItem("No revenge trading"),
          ],
        ),
      ),
    );
  }
}

class _MissionItem extends StatelessWidget {
  final String title;

  const _MissionItem(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 22,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}