import 'package:flutter/material.dart';

import 'widgets/greeting_card.dart';
import 'widgets/decision_score_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              GreetingCard(),
              SizedBox(height: 20),
              DecisionScoreCard(),
            ],
          ),
        ),
      ),
    );
  }
}