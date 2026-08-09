import 'package:flutter/material.dart';

import '../../../core/analysis/analysis_engine.dart';
import '../../../core/analysis/policy/decision_policy.dart';
import '../../../core/analysis/policy/policy_result.dart';
import '../../../core/services/market_data_service.dart';
import '../../../core/services/news_safety_service.dart';
import '../../session/services/session_manager.dart';
import '../../trade_history/services/trade_history_service.dart';
import '../models/analysis_result.dart';

class AIDecisionScreen extends StatefulWidget {
  final String market;
  final String direction;

  const AIDecisionScreen({
    super.key,
    required this.market,
    required this.direction,
  });

  @override
  State<AIDecisionScreen> createState() => _AIDecisionScreenState();
}

class _AIDecisionScreenState extends State<AIDecisionScreen> {
  final MarketDataService _marketDataService = MarketDataService();

  final TradeHistoryService _tradeHistoryService = TradeHistoryService();

  final NewsSafetyService _newsSafetyService = NewsSafetyService();

  AnalysisResult? _result;
  PolicyResult? _policyResult;

  int _tradesToday = 0;

  bool _loading = true;
  String? _error;

  String get _strategyTimeframe {
    final timeframe = SessionManager.instance.session.strategyTimeframe.trim();

    if (timeframe.isEmpty) {
      return '3 min';
    }

    return timeframe;
  }

  @override
  void initState() {
    super.initState();
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    try {
      final session = SessionManager.instance.session;

      if (session.strategyId.trim().isEmpty ||
          session.strategy.trim().isEmpty) {
        if (!mounted) {
          return;
        }

        setState(() {
          _loading = false;
          _error =
              'No strategy is selected. Please select an active strategy before analyzing a trade.';
        });

        return;
      }

      final snapshot = await _marketDataService.fetchSnapshot(
        market: widget.market,
        timeframe: _strategyTimeframe,
      );

      final result = AnalysisEngine.analyze(
  market: widget.market,
  direction: widget.direction,
  candles: snapshot.candles,
  optionChain: snapshot.optionChain,
  oiData: snapshot.oiData,
  heatMap: snapshot.heatMap,
  sectorStrength: snapshot.sectorStrength,

  bidPrice: snapshot.bidPrice,
  askPrice: snapshot.askPrice,
  bidQuantity: snapshot.bidQuantity,
  askQuantity: snapshot.askQuantity,
);

      final tradesToday = await _tradeHistoryService.getTodayTradeCount(
        strategyId: session.strategyId,
      );

      // REAL NEWS SAFETY CONNECTION
      //
      // If the selected strategy has Avoid News enabled,
      // Quanttora asks the backend /news/safety endpoint.
      //
      // If Avoid News is disabled, the news gate is bypassed.
      final NewsSafetyResult newsSafety;

      if (session.strategyAvoidNews) {
        newsSafety = await _newsSafetyService.evaluate();
      } else {
        newsSafety = const NewsSafetyResult(
          dataAvailable: true,
          highImpactNews: false,
          reason: 'News safety filter is disabled for this strategy.',
          matchedHeadlines: [],
        );
      }

      final policyResult = DecisionPolicy.evaluate(
        aiConfidence: result.confidence,
        minimumAiScore: session.strategyMinimumAiScore,
        avoidSidewaysMarket: session.strategyAvoidSideways,
        avoidLowVolume: session.strategyAvoidLowVolume,
        avoidNews: session.strategyAvoidNews,

        // REAL NEWS SAFETY VALUES
        newsDataAvailable: newsSafety.dataAvailable,
        highImpactNews: newsSafety.highImpactNews,

        trend: result.trend,
        volume: result.volume,
        tradesToday: tradesToday,
        maxTradesPerDay: session.strategyMaxTradesPerDay,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _result = result;
        _policyResult = policyResult;
        _tradesToday = tradesToday;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(title: const Text('AI Decision Report')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Analyzing market and strategy rules...',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 50, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Unable to complete analysis.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });

                  _runAnalysis();
                },
                child: const Text('RETRY'),
              ),
            ],
          ),
        ),
      );
    }

    final result = _result!;
    final policy = _policyResult!;
    final session = SessionManager.instance.session;

    final decisionColor = policy.allowed ? Colors.green : Colors.red;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Column(
            children: [
              const Text(
                'Q-SCORE',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${result.confidence}%',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  color: decisionColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        _buildDecisionCard(policy: policy),

        const SizedBox(height: 24),

        if (session.strategy.isNotEmpty) _tile('Strategy', session.strategy),

        _tile('Market', result.market),

        _tile('Direction', result.direction),

        _tile('Timeframe', _strategyTimeframe),

        _tile(
          'Minimum AI Score',
          session.strategyMinimumAiScore > 0
              ? '${session.strategyMinimumAiScore}%'
              : 'Not configured',
        ),

        _tile(
          'Daily Trades',
          session.strategyMaxTradesPerDay > 0
              ? '$_tradesToday/'
                    '${session.strategyMaxTradesPerDay}'
              : 'Not configured',
        ),

        _tile(
          'Risk : Reward',
          session.strategyRiskRewardRatio > 0
              ? '1:${_formatRatio(session.strategyRiskRewardRatio)}'
              : session.riskReward,
        ),

        _tile('Market Health', '${result.marketHealth}/100'),

        _tile('Trend', result.trend),

        _tile('Momentum', result.momentum),

        _tile('Volume', result.volume),

        _tile('Liquidity', result.liquidity),

_tile(
  'Liquidity Sweep',
  result.liquiditySweep,
),

_tile(
  'Smart Money',
  result.smartMoney,
),

_tile(
  'Volatility',
  result.volatility,
),

        _tile('Sector Strength', result.sectorStrength),

        _tile('Heat Map', result.heatMap),

        _tile('Risk', result.risk),

        const SizedBox(height: 25),

        if (policy.passedRules.isNotEmpty) ...[
          const Text(
            'Strategy Rules Passed',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          ...policy.passedRules.map(
            (rule) => Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(rule),
              ),
            ),
          ),

          const SizedBox(height: 25),
        ],

        if (policy.blockingReasons.isNotEmpty) ...[
          const Text(
            'Trade Blocking Reasons',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          ...policy.blockingReasons.map(
            (reason) => Card(
              child: ListTile(
                leading: const Icon(Icons.block_rounded, color: Colors.red),
                title: Text(reason),
              ),
            ),
          ),

          const SizedBox(height: 25),
        ],

        const Text(
          'AI Analysis',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 15),

        ...result.reasons.map(
          (reason) => Card(
            child: ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: Text(reason),
            ),
          ),
        ),

        const SizedBox(height: 30),

        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: policy.allowed
                ? () {
                    // Broker execution remains intentionally
                    // disconnected until remaining Gate 3
                    // protections are completed.
                  }
                : null,
            child: Text(
              policy.allowed ? 'ELIGIBLE TO PROCEED' : 'TRADE BLOCKED',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        if (policy.allowed) ...[
          const SizedBox(height: 12),
          const Text(
            'Current implemented strategy gates have passed. '
            'Broker execution remains disabled until the '
            'remaining Quanttora safety gates are completed.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }

  Widget _buildDecisionCard({required PolicyResult policy}) {
    final allowed = policy.allowed;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: allowed
            ? Colors.green.withValues(alpha: 0.08)
            : Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: allowed
              ? Colors.green.withValues(alpha: 0.35)
              : Colors.red.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            allowed ? Icons.verified_rounded : Icons.block_rounded,
            color: allowed ? Colors.green : Colors.red,
            size: 34,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allowed ? 'STRATEGY GATES PASSED' : 'NO TRADE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: allowed ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  allowed
                      ? 'All currently implemented strategy '
                            'rules have passed.'
                      : '${policy.blockingReasons.length} '
                            'strategy rule(s) blocked this trade.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _formatRatio(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }
}
