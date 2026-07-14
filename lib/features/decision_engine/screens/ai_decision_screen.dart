import 'package:flutter/material.dart';

import '../../../core/decision/decision.dart';
import '../../../core/decision/decision_engine.dart';
import '../../../core/indicators/ema_indicator.dart';
import '../../../core/scoring/score_engine.dart';
import '../../../core/strategy/strategy.dart';
import '../../session/services/session_manager.dart';

class AIDecisionScreen extends StatelessWidget {
  const AIDecisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionManager.instance.session;

    final strategy = Strategy(
      id: "current",
      name: session.strategy,
      market: session.instrument,
      tradingMode: session.tradingMode,
      indicators: const [
        EmaIndicator(
          priceAboveEma22: true,
          ema22AboveEma33: true,
          emaSlopeUp: true,
        ),
      ],
    );

    final score = const ScoreEngine().calculate(strategy);

    final Decision decision =
        const DecisionEngine().evaluate(score);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quanttora AI"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.circle,
                  color: Colors.green,
                  size: 12,
                ),
                SizedBox(width: 8),
                Text(
                  "LIVE MARKET",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              "Current Trading Session",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _SessionTile(
              icon: Icons.account_balance,
              title: "Broker",
              value: session.broker,
            ),

            const SizedBox(height: 12),

            _SessionTile(
              icon: Icons.show_chart,
              title: "Instrument",
              value: session.instrument,
            ),

            const SizedBox(height: 12),

            _SessionTile(
              icon: Icons.flash_on,
              title: "Trading Mode",
              value: session.tradingMode,
            ),

            const SizedBox(height: 12),

            _SessionTile(
              icon: Icons.auto_graph,
              title: "Strategy",
              value: session.strategy,
            ),

            const SizedBox(height: 30),

            const Center(
              child: Text(
                "Q-SCORE™",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.green,
                    width: 10,
                  ),
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      score.percentage
                          .toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      decision.marketReadiness
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: [
                  _MetricTile(
                    title: "Probability",
                    value:
                        "${decision.probability.toStringAsFixed(0)}%",
                  ),
                  _MetricTile(
                    title: "Capital",
                    value:
                        decision.capitalProtection,
                  ),
                  _MetricTile(
                    title: "Strategy",
                    value: decision
                            .strategyAligned
                        ? "Aligned"
                        : "Review",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "AI Assessment",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            ...decision.strengths.map(
              (e) => _FindingTile(
                icon: Icons.check_circle,
                color: Colors.green,
                text: e,
              ),
            ),

            const SizedBox(height: 16),

            ...decision.weaknesses.map(
              (e) => _FindingTile(
                icon: Icons.warning_amber,
                color: Colors.orange,
                text: e,
              ),
            ),
                        const SizedBox(height: 30),

            const Text(
              "Next Confirmations",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            ...decision.nextConfirmations.map(
              (e) => _FindingTile(
                icon: Icons.schedule,
                color: Colors.blue,
                text: e,
              ),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Quanttora Insight",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "${decision.probability.toStringAsFixed(0)}% of your selected strategy conditions are currently satisfied.",
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Market Readiness : ${decision.marketReadiness}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Capital Protection : ${decision.capitalProtection}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    decision.strategyAligned
                        ? "Your strategy is aligned with the current market."
                        : "Wait for additional confirmations before considering execution.",
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.analytics_outlined),
                label: const Text(
                  "VIEW INDICATOR DETAILS",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.account_balance),
                label: const Text(
                  "OPEN CONNECTED BROKER",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SessionTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blue,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Text(
            value.isEmpty ? "-" : value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String title;
  final String value;

  const _MetricTile({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
class _FindingTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _FindingTile({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}