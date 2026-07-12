import 'package:flutter/material.dart';

class AIVerdictCard extends StatelessWidget {
  const AIVerdictCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            const Icon(
              Icons.smart_toy_rounded,
              color: Color(0xFF2563EB),
              size: 48,
            ),

            const SizedBox(height: 16),

            const Text(
              "AI VERDICT",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 22,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8EC),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [

                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 56,
                  ),

                  SizedBox(height: 10),

                  Text(
                    "EXECUTE",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Confidence 94%",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Reason",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 14),

            const _ReasonTile("Strong market trend detected"),
            const _ReasonTile("Healthy trading volume"),
            const _ReasonTile("Risk : Reward ratio is 1 : 3"),
            const _ReasonTile("Trading psychology is stable"),
            const _ReasonTile("Strategy conditions are satisfied"),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text(
                  "EXECUTE TRADE",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.close),
                label: const Text(
                  "CANCEL",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  final String text;

  const _ReasonTile(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [

          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 22,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),

        ],
      ),
    );
  }
}