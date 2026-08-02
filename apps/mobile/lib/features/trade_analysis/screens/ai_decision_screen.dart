import 'package:flutter/material.dart';

import '../../../core/analysis/analysis_engine.dart';
import '../../../core/services/market_data_service.dart';
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
  State<AIDecisionScreen> createState() =>
      _AIDecisionScreenState();
}

class _AIDecisionScreenState
    extends State<AIDecisionScreen> {
  final MarketDataService _marketDataService =
      MarketDataService();

  AnalysisResult? _result;

  bool _loading = true;

  String? _error;

  @override
  void initState() {
    super.initState();

    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    try {
      final snapshot =
          await _marketDataService.fetchSnapshot(
        market: widget.market,
        timeframe: '3 min',
      );

      final result = AnalysisEngine.analyze(
        market: widget.market,
        direction: widget.direction,
        candles: snapshot.candles,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _result = result;
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
      appBar: AppBar(
        title: const Text(
          'AI Decision Report',
        ),
      ),
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
              'Analyzing real market data...',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
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
              const Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to complete analysis.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });

                  _runAnalysis();
                },
                child: const Text(
                  'RETRY',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final result = _result!;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Column(
            children: [
              const Text(
                'AI CONFIDENCE',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${result.confidence}%',
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        _tile(
          'Market',
          result.market,
        ),

        _tile(
          'Direction',
          result.direction,
        ),

        _tile(
          'Market Health',
          '${result.marketHealth}/100',
        ),

        _tile(
          'Trend',
          result.trend,
        ),

        _tile(
          'Momentum',
          result.momentum,
        ),

        _tile(
          'Volume',
          result.volume,
        ),

        _tile(
          'Liquidity',
          result.liquidity,
        ),

        _tile(
          'Volatility',
          result.volatility,
        ),

        _tile(
          'Sector Strength',
          result.sectorStrength,
        ),

        _tile(
          'Heat Map',
          result.heatMap,
        ),

        _tile(
          'Risk',
          result.risk,
        ),

        const SizedBox(height: 25),

        const Text(
          'AI Reasons',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 15),

        ...result.reasons.map(
          (reason) => Card(
            child: ListTile(
              leading: const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              title: Text(reason),
            ),
          ),
        ),

        const SizedBox(height: 30),

        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () {},
            child: const Text(
              'PROCEED TO BROKER',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tile(
    String title,
    String value,
  ) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}