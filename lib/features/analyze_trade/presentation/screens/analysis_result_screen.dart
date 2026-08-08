import 'package:flutter/material.dart';

class AnalysisResultScreen extends StatelessWidget {
  const AnalysisResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),
      appBar: AppBar(
        title: const Text("AI Analysis Result"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text(
                    "AI CONFIDENCE",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 170,
                        height: 170,
                        child: CircularProgressIndicator(
                          value: .92,
                          strokeWidth: 14,
                          color: Colors.green,
                          backgroundColor: Colors.grey.shade300,
                        ),
                      ),

                      const Column(
                        children: [
                          Text(
                            "92",
                            style: TextStyle(
                              fontSize: 46,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            "Excellent",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Text(
                      "EXECUTE",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _sectionTitle("Checks"),

            const SizedBox(height: 10),

            const _ResultTile("Trend", true),
            const _ResultTile("EMA", true),
            const _ResultTile("VWAP", true),
            const _ResultTile("RSI", true),
            const _ResultTile("Volume", false),
            const _ResultTile("ATR", true),
            const _ResultTile("Risk Reward", true),
            const _ResultTile("Trading Constitution", true),

            const SizedBox(height: 25),

            _sectionTitle("AI Reasoning"),

            const SizedBox(height: 10),

            const _ReasonTile(
              Icons.check_circle,
              Colors.green,
              "Trend is bullish.",
            ),

            const _ReasonTile(
              Icons.check_circle,
              Colors.green,
              "Price is above VWAP.",
            ),

            const _ReasonTile(
              Icons.check_circle,
              Colors.green,
              "Risk Reward is 1 : 3.",
            ),

            const _ReasonTile(
              Icons.cancel,
              Colors.red,
              "Volume is below average.",
            ),

            const SizedBox(height: 25),

            _sectionTitle("Trade Levels"),

            const SizedBox(height: 10),

            const Row(
              children: [
                Expanded(
                  child: _LevelCard(
                    title: "ENTRY",
                    value: "25135",
                    color: Colors.blue,
                  ),
                ),

                SizedBox(width: 10),

                Expanded(
                  child: _LevelCard(
                    title: "STOP LOSS",
                    value: "25080",
                    color: Colors.red,
                  ),
                ),

                SizedBox(width: 10),

                Expanded(
                  child: _LevelCard(
                    title: "TARGET",
                    value: "25300",
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  "Execute Trade",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final String title;
  final bool passed;

  const _ResultTile(this.title, this.passed);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          passed ? Icons.check_circle : Icons.cancel,
          color: passed ? Colors.green : Colors.red,
        ),
        title: Text(title),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _ReasonTile(this.icon, this.color, this.text);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(text),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _LevelCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
