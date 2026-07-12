import 'package:flutter/material.dart';

class DecisionEngineScreen extends StatelessWidget {
  const DecisionEngineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Decision Engine"),
      ),
      body: const Center(
        child: Text(
          "Decision Engine Connected ✅",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}