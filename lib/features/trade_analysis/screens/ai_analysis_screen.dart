import 'dart:async';

import 'package:flutter/material.dart';

import 'ai_decision_screen.dart';

class AIAnalysisScreen extends StatefulWidget {
  final String market;
  final String direction;

  const AIAnalysisScreen({
    super.key,
    required this.market,
    required this.direction,
  });

  @override
  State<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen> {

  final List<String> steps = [
    "Market Structure",
    "Trend Strength",
    "Multi Timeframe",
    "Volume Analysis",
    "VWAP",
    "EMA Alignment",
    "ADX",
    "RSI",
    "Volatility",
    "Liquidity",
    "Risk Analysis",
    "Generating AI Decision",
  ];

  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    startScan();
  }

  void startScan() {

    Timer.periodic(
      const Duration(milliseconds: 700),
      (timer) {

        if (!mounted) return;

        if (currentStep < steps.length - 1) {

          setState(() {
            currentStep++;
          });

        } else {

          timer.cancel();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AIDecisionScreen(
                market: widget.market,
                direction: widget.direction,
              ),
            ),
          );

        }

      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("AI Analysis"),
      ),

      body: ListView.builder(

        padding: const EdgeInsets.all(20),

        itemCount: steps.length,

        itemBuilder: (_, index) {

          final completed = index < currentStep;
          final scanning = index == currentStep;

          return Card(

            child: ListTile(

              leading: completed
                  ? const Icon(Icons.check_circle,color:Colors.green)
                  : scanning
                  ? const SizedBox(
                width:24,
                height:24,
                child:CircularProgressIndicator(strokeWidth:3),
              )
                  : const Icon(Icons.schedule),

              title: Text(
                steps[index],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(
                completed
                    ? "Completed"
                    : scanning
                    ? "Scanning..."
                    : "Waiting",
              ),

            ),

          );

        },

      ),

    );

  }

}