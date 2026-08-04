import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/market_data_service.dart';
import '../../core/widgets/responsive_container.dart';

import 'widgets/market_overview_card.dart';
import 'widgets/quick_actions_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MarketDataService _marketService = MarketDataService();

  bool _loading = true;
  bool _marketConnected = false;

  Timer? _timer;

  MarketIndex _nifty = const MarketIndex(
    name: 'NIFTY 50',
    value: '--',
    change: 0,
    changeText: 'Unavailable',
  );

  MarketIndex _sensex = const MarketIndex(
    name: 'SENSEX',
    value: '--',
    change: 0,
    changeText: 'Unavailable',
  );

  MarketIndex _bankNifty = const MarketIndex(
    name: 'BANK NIFTY',
    value: '--',
    change: 0,
    changeText: 'Unavailable',
  );

  @override
  void initState() {
    super.initState();

    _loadDashboard();

    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadDashboard(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    try {
      final dashboard =
          await _marketService.fetchMarketDashboard();

      final indices =
          dashboard['indices'] as Map<String, dynamic>? ??
              <String, dynamic>{};

      final connected =
          dashboard['connected'] == true;

      final nifty = _buildMarketIndex(
        name: 'NIFTY 50',
        data: indices['nifty'],
      );

      final sensex = _buildMarketIndex(
        name: 'SENSEX',
        data: indices['sensex'],
      );

      final bankNifty = _buildMarketIndex(
        name: 'BANK NIFTY',
        data: indices['bankNifty'],
      );

      if (!mounted) return;

      setState(() {
        _nifty = nifty;
        _sensex = sensex;
        _bankNifty = bankNifty;
        _marketConnected = connected;
        _loading = false;
      });
    } catch (error) {
      debugPrint(
        'Home dashboard market data error: $error',
      );

      if (!mounted) return;

      setState(() {
        _marketConnected = false;
        _loading = false;
      });
    }
  }

  MarketIndex _buildMarketIndex({
    required String name,
    required dynamic data,
  }) {
    if (data is! Map) {
      return MarketIndex(
        name: name,
        value: '--',
        change: 0,
        changeText: 'Unavailable',
      );
    }

    final ltp = _toDouble(data['ltp']);
    final previousClose = _toDouble(data['change']);

    if (ltp <= 0) {
      return MarketIndex(
        name: name,
        value: '--',
        change: 0,
        changeText: 'Unavailable',
      );
    }

    double change = 0;
    double changePercent = 0;

    if (previousClose > 0) {
      change = ltp - previousClose;
      changePercent =
          (change / previousClose) * 100;
    }

    final prefix = change > 0 ? '+' : '';

    return MarketIndex(
      name: name,
      value: ltp.toStringAsFixed(2),
      change: change,
      changeText: previousClose > 0
          ? '$prefix${change.toStringAsFixed(2)} '
              '($prefix${changePercent.toStringAsFixed(2)}%)'
          : 'Price available',
    );
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboard,
          child: ResponsiveContainer(
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                vertical: 20,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quanttora',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _marketConnected
                            ? 'Market data connected'
                            : 'Market data unavailable',
                        style: TextStyle(
                          color: _marketConnected
                              ? Colors.green
                              : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                MarketOverviewCard(
                  nifty: _nifty,
                  sensex: _sensex,
                  bankNifty: _bankNifty,
                  isLive: _marketConnected,
                ),

                const SizedBox(height: 18),

                const QuickActionsCard(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}