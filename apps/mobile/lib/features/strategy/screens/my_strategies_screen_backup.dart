import 'package:flutter/material.dart';

import '../../decision_engine/screens/ai_decision_screen.dart';
import '../../session/services/session_manager.dart';

class MyStrategiesScreen extends StatelessWidget {
  const MyStrategiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strategies = [
      Strategy(
        name: "NIFTY Scalping",
        mode: "Scalping",
        market: "NIFTY 50",
        risk: "1%",
        rr: "1 : 3",
        color: Colors.orange,
      ),
      Strategy(
        name: "BANKNIFTY Expiry",
        mode: "Scalping",
        market: "BANKNIFTY",
        risk: "1%",
        rr: "1 : 2",
        color: Colors.blue,
      ),
      Strategy(
        name: "Swing Stocks",
        mode: "Swing",
        market: "NSE Stocks",
        risk: "2%",
        rr: "1 : 4",
        color: Colors.green,
      ),
      Strategy(
        name: "Hedge Pro",
        mode: "Hedge",
        market: "Indices",
        risk: "Low",
        rr: "Protected",
        color: Colors.red,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Strategies"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_rounded),
        label: const Text("Create Strategy"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose Strategy",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Quanttora AI will analyze using your selected strategy.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: ListView.builder(
                itemCount: strategies.length,
                itemBuilder: (context, index) {
                  final item = strategies[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        SessionManager.instance
                            .updateStrategy(item.name);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AIDecisionScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor:
                                      item.color.withValues(alpha: 0.15),
                                  child: Icon(
                                    Icons.auto_graph_rounded,
                                    color: item.color,
                                  ),
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "${item.mode} • ${item.market}",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 18,
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            Row(
                              children: [
                                _InfoChip(
                                  title: "Risk",
                                  value: item.risk,
                                ),
                                const SizedBox(width: 12),
                                _InfoChip(
                                  title: "RR",
                                  value: item.rr,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String title;
  final String value;

  const _InfoChip({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
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

class Strategy {
  final String name;
  final String mode;
  final String market;
  final String risk;
  final String rr;
  final Color color;

  const Strategy({
    required this.name,
    required this.mode,
    required this.market,
    required this.risk,
    required this.rr,
    required this.color,
  });
}