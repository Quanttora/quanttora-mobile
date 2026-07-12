import 'package:flutter/material.dart';

class DecisionScoreCard extends StatelessWidget {
  const DecisionScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            const Row(
              children: [

                Icon(
                  Icons.psychology_alt_rounded,
                  color: Color(0xFF2563EB),
                  size: 30,
                ),

                SizedBox(width: 10),

                Text(
                  "Decision Score",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 30),

            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2563EB),
                  width: 10,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Text(
                    "91",
                    style: TextStyle(
                      fontSize: 58,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "/100",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey,
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F1FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                children: [

                  Text(
                    "AI Confidence",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "94%",
                    style: TextStyle(
                      fontSize: 36,
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Excellent trade quality detected.\nAll major conditions are aligned.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),

          ],
        ),
      ),
    );
  }
}