import 'package:flutter/material.dart';

class RiskAnalysisCard extends StatelessWidget {
  const RiskAnalysisCard({super.key});

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
                  Icons.shield_rounded,
                  color: Color(0xFF2563EB),
                ),

                SizedBox(width: 10),

                Text(
                  "Risk Analysis",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 10),

            const Text(
              "Protect your capital before chasing profits.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            const _RiskRow(
              title: "Capital",
              value: "₹50,000",
              color: Colors.black,
            ),

            const Divider(),

            const _RiskRow(
              title: "Risk Per Trade",
              value: "₹1,000",
              color: Colors.orange,
            ),

            const Divider(),

            const _RiskRow(
              title: "Reward",
              value: "₹3,000",
              color: Colors.green,
            ),

            const Divider(),

            const _RiskRow(
              title: "Risk : Reward",
              value: "1 : 3",
              color: Colors.blue,
            ),

            const Divider(),

            const _RiskRow(
              title: "Position Size",
              value: "2 Lots",
              color: Colors.deepPurple,
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEFFAF3),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [

                  Icon(
                    Icons.verified,
                    color: Colors.green,
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      "Risk is within your trading plan. This trade respects your maximum daily loss and target Risk : Reward ratio.",
                      style: TextStyle(
                        height: 1.5,
                        fontSize: 15,
                      ),
                    ),
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class _RiskRow extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _RiskRow({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

        ],
      ),
    );
  }
}