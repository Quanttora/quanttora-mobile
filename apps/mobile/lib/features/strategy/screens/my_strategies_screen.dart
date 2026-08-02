import 'package:flutter/material.dart';

import '../../decision_engine/screens/ai_decision_screen.dart';
import '../../session/services/session_manager.dart';
import '../data/supabase_strategy_repository.dart';
import '../models/strategy_model.dart';

class MyStrategiesScreen extends StatefulWidget {
  const MyStrategiesScreen({super.key});

  @override
  State<MyStrategiesScreen> createState() =>
      _MyStrategiesScreenState();
}

class _MyStrategiesScreenState
    extends State<MyStrategiesScreen> {
  final SupabaseStrategyRepository _repository =
      SupabaseStrategyRepository();

  late Future<List<StrategyModel>> _strategiesFuture;

  @override
  void initState() {
    super.initState();
    _loadStrategies();
  }

  void _loadStrategies() {
    _strategiesFuture = _repository.getActiveStrategies();
  }

  Future<void> _refreshStrategies() async {
    setState(() {
      _loadStrategies();
    });

    await _strategiesFuture;
  }

  void _selectStrategy(StrategyModel strategy) {
    SessionManager.instance.selectStrategy(strategy);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AIDecisionScreen(),
      ),
    );
  }

  String _formatRatio(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Strategies'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<StrategyModel>>(
        future: _strategiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _loadStrategies();
                });
              },
            );
          }

          final strategies =
              snapshot.data ?? const <StrategyModel>[];

          if (strategies.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshStrategies,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 120),
                  Icon(
                    Icons.auto_graph_rounded,
                    size: 72,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No active strategies',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Create or activate a strategy first, then return here to use it for trade analysis.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshStrategies,
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Choose Strategy',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Quanttora AI will analyze the trade using your selected active strategy.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                ...strategies.map(
                  (strategy) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: 18),
                    child: _StrategySelectionCard(
                      strategy: strategy,
                      riskReward:
                          '1:${_formatRatio(strategy.riskRewardRatio)}',
                      onTap: () =>
                          _selectStrategy(strategy),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StrategySelectionCard extends StatelessWidget {
  final StrategyModel strategy;
  final String riskReward;
  final VoidCallback onTap;

  const _StrategySelectionCard({
    required this.strategy,
    required this.riskReward,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final instruments = strategy.instruments.isEmpty
        ? 'No instrument'
        : strategy.instruments.join(', ');

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
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
              color: Colors.black.withValues(
                alpha: 0.05,
              ),
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
                      Colors.blue.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.auto_graph_rounded,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        strategy.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$instruments • ${strategy.timeframe}',
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
                  title: 'R:R',
                  value: riskReward,
                ),
                const SizedBox(width: 10),
                _InfoChip(
                  title: 'AI Score',
                  value:
                      '${strategy.minimumAiScore}+',
                ),
                const SizedBox(width: 10),
                _InfoChip(
                  title: 'Max Trades',
                  value:
                      strategy.maxTradesPerDay.toString(),
                ),
              ],
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
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load strategies',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}