import 'package:flutter/material.dart';

import 'widgets/decision_score_card.dart';
import 'widgets/market_analysis_card.dart';
import 'widgets/strategy_analysis_card.dart';
import 'widgets/risk_analysis_card.dart';
import 'widgets/psychology_analysis_card.dart';
import 'widgets/ai_verdict_card.dart';

class DecisionEngineScreen extends StatelessWidget {
  const DecisionEngineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Quanttora Decision Engine",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [

            DecisionScoreCard(),

            SizedBox(height: 20),

            MarketAnalysisCard(),

            SizedBox(height: 20),

            StrategyAnalysisCard(),

            SizedBox(height: 20),

            RiskAnalysisCard(),

            SizedBox(height: 20),

            PsychologyAnalysisCard(),

            SizedBox(height: 20),

            AIVerdictCard(),

            SizedBox(height: 40),

          ],
        ),
      ),
    );
  }
}