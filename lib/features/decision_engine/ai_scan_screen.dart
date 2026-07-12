import 'dart:async';

import 'package:flutter/material.dart';

import 'decision_report_screen.dart';

class AIScanScreen extends StatefulWidget {
  const AIScanScreen({super.key});

  @override
  State<AIScanScreen> createState() => _AIScanScreenState();
}

class _AIScanScreenState extends State<AIScanScreen> {
  int currentStep = 0;

  final List<String> steps = [
    "Connecting to Market...",
    "Checking Market Trend...",
    "Checking Momentum...",
    "Checking Risk Management...",
    "Checking Strategy...",
    "Checking Trading Psychology...",
    "Generating Q-Score™...",
  ];

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    for (int i = 0; i < steps.length; i++) {
      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return;

      setState(() {
        currentStep = i + 1;
      });
    }

    await Future.delayed(
      const Duration(milliseconds: 600),
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const DecisionReportScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.psychology_alt_rounded,
                  color: Color(0xFF2563EB),
                  size: 90,
                ),

                const SizedBox(height: 20),

                const Text(
                  "QUANTTORA AI",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Analyzing your trade...",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: currentStep / steps.length,
                    minHeight: 10,
                  ),
                ),

                const SizedBox(height: 35),

                Expanded(
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: steps.length,
                    itemBuilder: (context, index) {
                      final completed = index < currentStep;

                      return ListTile(
                        leading: Icon(
                          completed
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color:
                              completed ? Colors.green : Colors.grey,
                        ),
                        title: Text(
                          steps[index],
                          style: TextStyle(
                            fontWeight: completed
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}