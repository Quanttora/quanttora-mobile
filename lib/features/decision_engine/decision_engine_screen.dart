import 'package:flutter/material.dart';

import '../../core/decision_engine/decision_engine.dart';
import '../../core/decision_engine/market_rules.dart';
import '../../core/decision_engine/momentum_rules.dart';
import '../../core/decision_engine/risk_rules.dart';
import '../../core/decision_engine/strategy_rules.dart';
import '../../core/decision_engine/psychology_rules.dart';

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

    final engine = DecisionEngine(
      market: const MarketRules(
        priceAboveEma22: true,
        ema22AboveEma33: true,
        higherHigh: true,
        higherLow: true,
        aboveVwap: true,
      ),
      momentum: const MomentumRules(
        adxAbove25: true,
        rsiHealthy: true,
        volumeAboveAverage: true,
        strongCandle: false,
      ),
      risk: const RiskRules(
        riskRewardRatio: 3,
        riskPercent: 2,
      ),
      strategy: const StrategyRules(
        breakout: true,
        retest: false,
        liquiditySweep: true,
        confirmationCandle: true,
      ),
      psychology: const PsychologyRules(
        tradesToday: 1,
        revengeTrading: false,
        dailyLossLimitHit: false,
      ),
    );

    final result = engine.evaluate();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Decision Engine"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              DecisionScoreCard(result: result),

              const SizedBox(height: 20),

              MarketAnalysisCard(result: result),

              const SizedBox(height: 20),

              StrategyAnalysisCard(result: result),

              const SizedBox(height: 20),

              RiskAnalysisCard(result: result),

              const SizedBox(height: 20),

              PsychologyAnalysisCard(result: result),

              const SizedBox(height: 20),

              AIVerdictCard(result: result),

              const SizedBox(height: 40),

            ],
          ),
        ),
      ),
    );
  }
}