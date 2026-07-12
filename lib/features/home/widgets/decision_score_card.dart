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
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Row(
              children: [

                Icon(
                  Icons.psychology_alt_rounded,
                  color: Color(0xFF2563EB),
                  size: 28,
                ),

                SizedBox(width: 10),

                Text(
                  "Decision DNA",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            const Text(
              "Your trading quality based on discipline, patience and execution.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 28),

            Row(
              children: [

                Expanded(
                  flex: 2,
                  child: Column(
                    children: [

                      Stack(
                        alignment: Alignment.center,
                        children: [

                          SizedBox(
                            width: 130,
                            height: 130,
                            child: CircularProgressIndicator(
                              value: .91,
                              strokeWidth: 12,
                              backgroundColor: Colors.grey.shade200,
                              color: const Color(0xFF2563EB),
                            ),
                          ),

                          const Column(
                            children: [

                              Text(
                                "91",
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                "/100",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),

                    ],
                  ),
                ),

                const SizedBox(width: 20),

                const Expanded(
                  flex: 3,
                  child: Column(
                    children: [

                      _ScoreBar(
                        title: "Discipline",
                        score: 95,
                        color: Colors.green,
                      ),

                      SizedBox(height: 18),

                      _ScoreBar(
                        title: "Patience",
                        score: 88,
                        color: Colors.orange,
                      ),

                      SizedBox(height: 18),

                      _ScoreBar(
                        title: "Risk Control",
                        score: 90,
                        color: Colors.blue,
                      ),

                      SizedBox(height: 18),

                      _ScoreBar(
                        title: "Execution",
                        score: 92,
                        color: Colors.deepPurple,
                      ),

                    ],
                  ),
                ),

              ],
            ),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [

                  Icon(
                    Icons.tips_and_updates,
                    color: Color(0xFF2563EB),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      "Excellent discipline this week. Focus on improving patience before entering breakout trades.",
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

class _ScoreBar extends StatelessWidget {
  final String title;
  final int score;
  final Color color;

  const _ScoreBar({
    required this.title,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            Text(
              "$score%",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),

          ],
        ),

        const SizedBox(height: 8),

        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            color: color,
          ),
        ),

      ],
    );
  }
}