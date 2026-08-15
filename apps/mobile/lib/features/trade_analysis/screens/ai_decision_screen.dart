import 'package:flutter/material.dart';

import '../../../core/analysis/analysis_engine.dart';
import '../../../core/analysis/policy/decision_policy.dart';
import '../../../core/analysis/policy/policy_result.dart';
import '../../../core/constitution/constitution_engine.dart';
import '../../../core/constitution/constitution_result.dart';
import '../../../core/services/market_data_service.dart';
import '../../../core/services/news_safety_service.dart';
import '../../broker/broker_service.dart';
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
  final BrokerService _brokerService = BrokerService();

  AnalysisResult? _result;
  PolicyResult? _policyResult;
  ConstitutionResult? _constitutionResult;

  int _tradesToday = 0;

  bool _loading = true;
  bool _paperTradeLoading = false;
  String? _error;
  String? _paperTradeMessage;
  bool? _paperTradeSuccess;

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

      final basePolicyResult = DecisionPolicy.evaluate(
        aiConfidence: result.confidence,
        minimumAiScore: session.strategyMinimumAiScore,
        avoidSidewaysMarket: session.strategyAvoidSideways,
        avoidLowVolume: session.strategyAvoidLowVolume,
        avoidNews: session.strategyAvoidNews,
        newsDataAvailable: newsSafety.dataAvailable,
        highImpactNews: newsSafety.highImpactNews,
        trend: result.trend,
        volume: result.volume,
        tradesToday: tradesToday,
        maxTradesPerDay: session.strategyMaxTradesPerDay,
      );

      final constitutionResult = const ConstitutionEngine().evaluate(
        tradesToday: tradesToday,
        maxTradesPerDay: session.strategyMaxTradesPerDay,
        dailyLoss: 0,
        maxDailyLoss: 0,
        riskReward: session.strategyRiskRewardRatio,
        minimumRiskReward: session.strategyRiskRewardRatio,
      );

      final blockingReasons = <String>[...basePolicyResult.blockingReasons];

      final passedRules = <String>[...basePolicyResult.passedRules];

      for (final rule in constitutionResult.rules) {
        if (rule.status.name == 'pass') {
          passedRules.add('Constitution: ${rule.title} passed.');
        } else {
          blockingReasons.add('Constitution: ${rule.title} failed.');
        }
      }

      final policyResult = PolicyResult(
        allowed: basePolicyResult.allowed && constitutionResult.canAnalyze,
        blockingReasons: blockingReasons,
        passedRules: passedRules,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _result = result;
        _policyResult = policyResult;
        _constitutionResult = constitutionResult;
        _tradesToday = tradesToday;
        _loading = false;
        _error = null;
        _paperTradeMessage = null;
        _paperTradeSuccess = null;
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

  String _instrumentKeyForMarket(String market) {
    final normalized = market.trim().toUpperCase();

    if (normalized.contains('BANK NIFTY') ||
        normalized.contains('NIFTY BANK')) {
      return 'NSE_INDEX|Nifty Bank';
    }

    if (normalized.contains('SENSEX')) {
      return 'BSE_INDEX|SENSEX';
    }

    if (normalized.contains('NIFTY')) {
      return 'NSE_INDEX|Nifty 50';
    }

    throw StateError(
      'No live Upstox instrument mapping is configured for "$market".',
    );
  }

  double _extractQuoteLtp(Map<String, dynamic> response) {
    final data = response['data'];

    if (data is! Map) {
      throw const FormatException(
        'Live quote response does not contain quote data.',
      );
    }

    for (final entry in data.entries) {
      final quote = entry.value;

      if (quote is! Map) {
        continue;
      }

      final candidates = <dynamic>[
        quote['last_price'],
        quote['lastPrice'],
        quote['ltp'],
        quote['LTP'],
      ];

      for (final candidate in candidates) {
        if (candidate is num && candidate.toDouble() > 0) {
          return candidate.toDouble();
        }

        final parsed = double.tryParse(candidate?.toString() ?? '');

        if (parsed != null && parsed > 0) {
          return parsed;
        }
      }
    }

    throw const FormatException(
      'Live LTP was not found in the Upstox quote response.',
    );
  }

  Future<void> _openPaperTradeDialog() async {
    if (_policyResult?.allowed != true || _result == null) {
      return;
    }

    final session = SessionManager.instance.session;
    final result = _result!;

    final instrumentKey = _instrumentKeyForMarket(widget.market);

    setState(() {
      _paperTradeLoading = true;
      _paperTradeMessage = null;
      _paperTradeSuccess = null;
    });

    double livePrice;

    try {
      final quoteResponse = await _brokerService.getQuote(
        instrumentKey: instrumentKey,
      );

      livePrice = _extractQuoteLtp(quoteResponse);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _paperTradeLoading = false;
        _paperTradeSuccess = false;
        _paperTradeMessage =
            'Unable to fetch live price for $instrumentKey: $e';
      });

      _showMessage('Unable to fetch live market price.', isError: true);

      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _paperTradeLoading = false;
    });

    String orderType = 'MARKET';
    String product = 'D';
    String validity = 'DAY';

    String transactionType =
        widget.direction.toUpperCase() == 'PUT' ||
            widget.direction.toUpperCase() == 'PE'
        ? 'SELL'
        : 'BUY';

    final quantityController = TextEditingController(text: '1');

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Start Paper Trade'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Live market data received. Review the simulated order.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'LIVE INSTRUMENT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            instrumentKey,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'LIVE LTP',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹ ${livePrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: orderType,
                      decoration: const InputDecoration(
                        labelText: 'Order Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'MARKET',
                          child: Text('MARKET'),
                        ),
                        DropdownMenuItem(value: 'LIMIT', child: Text('LIMIT')),
                        DropdownMenuItem(value: 'SL', child: Text('SL')),
                        DropdownMenuItem(value: 'SL-M', child: Text('SL-M')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            orderType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: product,
                      decoration: const InputDecoration(
                        labelText: 'Product',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'D', child: Text('Delivery')),
                        DropdownMenuItem(value: 'I', child: Text('Intraday')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            product = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: validity,
                      decoration: const InputDecoration(
                        labelText: 'Validity',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'DAY', child: Text('DAY')),
                        DropdownMenuItem(value: 'IOC', child: Text('IOC')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            validity = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: transactionType,
                      decoration: const InputDecoration(
                        labelText: 'Transaction',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'BUY', child: Text('BUY')),
                        DropdownMenuItem(value: 'SELL', child: Text('SELL')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            transactionType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _dialogSummary('Q-Score', '${result.confidence}%'),
                    _dialogSummary(
                      'Daily Trades',
                      '$_tradesToday/${session.strategyMaxTradesPerDay}',
                    ),
                    _dialogSummary(
                      'Risk : Reward',
                      '1:${_formatRatio(session.strategyRiskRewardRatio)}',
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  icon: const Icon(Icons.science_outlined),
                  label: const Text('START PAPER TRADE'),
                ),
              ],
            );
          },
        );
      },
    );

    final quantity = int.tryParse(quantityController.text.trim()) ?? 0;

    quantityController.dispose();

    if (submitted != true) {
      return;
    }

    if (quantity <= 0 || livePrice <= 0) {
      _showMessage('Quantity or live market price is invalid.', isError: true);
      return;
    }

    await _submitPaperTrade(
      instrumentToken: instrumentKey,
      quantity: quantity,
      product: product,
      validity: validity,
      price: livePrice,
      orderType: orderType,
      transactionType: transactionType,
    );
  }

  Future<void> _submitPaperTrade({
    required String instrumentToken,
    required int quantity,
    required String product,
    required String validity,
    required double price,
    required String orderType,
    required String transactionType,
  }) async {
    final result = _result;
    final policy = _policyResult;
    final session = SessionManager.instance.session;

    if (result == null || policy == null || !policy.allowed) {
      return;
    }

    setState(() {
      _paperTradeLoading = true;
      _paperTradeMessage = null;
      _paperTradeSuccess = null;
    });

    try {
      final response = await _brokerService.placePaperTrade(
        instrumentToken: instrumentToken,
        quantity: quantity,
        product: product,
        validity: validity,
        price: price,
        orderType: orderType,
        transactionType: transactionType,
        constitutionPassed: _constitutionResult?.canAnalyze ?? false,
        strategyPolicyPassed: policy.allowed,
        aiConfidence: result.confidence,
        minimumAiScore: session.strategyMinimumAiScore,
        tradesToday: _tradesToday,
        maxTradesPerDay: session.strategyMaxTradesPerDay,
        riskReward: session.strategyRiskRewardRatio,
        minimumRiskReward: session.strategyRiskRewardRatio,
      );

      final success = response['success'] == true;
      final message =
          response['message']?.toString() ??
          (success ? 'Paper trade approved.' : 'Paper trade was not approved.');

      if (!mounted) {
        return;
      }

      setState(() {
        _paperTradeLoading = false;
        _paperTradeSuccess = success;
        _paperTradeMessage = message;
      });

      _showMessage(message, isError: !success);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _paperTradeLoading = false;
        _paperTradeSuccess = false;
        _paperTradeMessage = e.toString();
      });

      _showMessage(e.toString(), isError: true);
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
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
        _buildExecutionPanel(policy: policy),
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
              ? '$_tradesToday/${session.strategyMaxTradesPerDay}'
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
        _tile('Liquidity Sweep', result.liquiditySweep),
        _tile('Smart Money', result.smartMoney),
        _tile('Volatility', result.volatility),
        _tile('Sector Strength', result.sectorStrength),
        _tile('Heat Map', result.heatMap),
        _tile('Risk', result.risk),
        const SizedBox(height: 25),
        if (_constitutionResult != null) ...[
          const Text(
            'Trading Constitution',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._constitutionResult!.rules.map((rule) {
            final passed = rule.status.name == 'pass';

            return Card(
              child: ListTile(
                leading: Icon(
                  passed ? Icons.verified_rounded : Icons.block_rounded,
                  color: passed ? Colors.green : Colors.red,
                ),
                title: Text(rule.title),
                subtitle: Text(rule.description),
                trailing: Text(
                  passed ? 'PASS' : 'FAIL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: passed ? Colors.green : Colors.red,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 25),
        ],
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
          child: ElevatedButton.icon(
            onPressed: policy.allowed && !_paperTradeLoading
                ? _openPaperTradeDialog
                : null,
            icon: Icon(
              policy.allowed ? Icons.science_outlined : Icons.block_rounded,
            ),
            label: Text(
              policy.allowed ? 'START PAPER TRADE' : 'TRADE BLOCKED',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        if (!policy.allowed) ...[
          const SizedBox(height: 10),
          const Text(
            'Paper trading is locked until every strategy and Constitution rule passes.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          ),
        ],
        if (policy.allowed) ...[
          const SizedBox(height: 10),
          const Text(
            'Paper trade only. No real broker order will be submitted.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
          ),
        ],
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildExecutionPanel({required PolicyResult policy}) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                allowed ? Icons.play_circle_fill_rounded : Icons.lock_rounded,
                color: allowed ? Colors.green : Colors.red,
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  allowed ? 'PAPER TRADE READY' : 'PAPER TRADE BLOCKED',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: allowed ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            allowed
                ? 'All current safety rules passed. You can simulate the trade without sending an order to Upstox.'
                : '${policy.blockingReasons.length} safety check(s) failed. Quanttora will not allow the paper trade until they pass.',
          ),
          if (_paperTradeMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _paperTradeSuccess == true
                    ? Colors.green.withValues(alpha: 0.10)
                    : Colors.red.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _paperTradeMessage!,
                style: TextStyle(
                  color: _paperTradeSuccess == true
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dialogSummary(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
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
                  allowed ? 'STRATEGY + CONSTITUTION PASSED' : 'NO TRADE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: allowed ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  allowed
                      ? 'All currently implemented strategy and Constitution rules have passed.'
                      : '${policy.blockingReasons.length} rule(s) blocked this trade.',
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
