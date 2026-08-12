import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/market_data_service.dart';
import '../../core/widgets/responsive_container.dart';
import '../broker/screens/upstox_login_screen.dart';
import '../watchlist/screens/watchlist_screen.dart';

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

      final indices = _extractIndices(dashboard);

      final connected =
          dashboard['connected'] == true ||
          dashboard['marketFeed'] == true ||
          dashboard['marketFeedConnected'] == true;

      final nifty = _buildMarketIndex(
        name: 'NIFTY 50',
        data: _findIndex(
          indices,
          const [
            'nifty',
            'NIFTY',
            'NIFTY 50',
            'nifty50',
          ],
        ),
      );

      final sensex = _buildMarketIndex(
        name: 'SENSEX',
        data: _findIndex(
          indices,
          const [
            'sensex',
            'SENSEX',
          ],
        ),
      );

      final bankNifty = _buildMarketIndex(
        name: 'BANK NIFTY',
        data: _findIndex(
          indices,
          const [
            'bankNifty',
            'bank_nifty',
            'BANKNIFTY',
            'BANK NIFTY',
          ],
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _nifty = nifty;
        _sensex = sensex;
        _bankNifty = bankNifty;
        _marketConnected =
            connected ||
            nifty.value != '--' ||
            sensex.value != '--' ||
            bankNifty.value != '--';
        _loading = false;
      });
    } catch (error) {
      debugPrint(
        '[Quanttora] Home dashboard error: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _marketConnected = false;
        _loading = false;
      });
    }
  }

  Map<String, dynamic> _extractIndices(
    Map<String, dynamic> dashboard,
  ) {
    dynamic value = dashboard['indices'];

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    final data = dashboard['data'];

    if (data is Map) {
      value = data['indices'];

      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }

    return <String, dynamic>{};
  }

  dynamic _findIndex(
    Map<String, dynamic> indices,
    List<String> keys,
  ) {
    for (final key in keys) {
      if (indices.containsKey(key)) {
        return indices[key];
      }
    }

    return null;
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

    final ltp = _firstDouble(
      data,
      const [
        'ltp',
        'last_price',
        'lastPrice',
        'close',
      ],
    );

    if (ltp <= 0) {
      return MarketIndex(
        name: name,
        value: '--',
        change: 0,
        changeText: 'Unavailable',
      );
    }

    final directChange = _firstDouble(
      data,
      const [
        'change',
        'changeValue',
        'netChange',
        'net_change',
      ],
    );

    final directChangePercent = _firstDouble(
      data,
      const [
        'changePercent',
        'change_percent',
        'percentageChange',
        'percentage_change',
      ],
    );

    final previousClose = _firstDouble(
      data,
      const [
        'previousClose',
        'previous_close',
        'prevClose',
        'prev_close',
      ],
    );

    double change = directChange;
    double changePercent = directChangePercent;

    if (previousClose > 0) {
      change = ltp - previousClose;
      changePercent = (change / previousClose) * 100;
    }

    final prefix = change > 0 ? '+' : '';

    final changeText =
        changePercent != 0 || change != 0
            ? '$prefix${change.toStringAsFixed(2)} '
              '($prefix${changePercent.toStringAsFixed(2)}%)'
            : 'Price available';

    return MarketIndex(
      name: name,
      value: ltp.toStringAsFixed(2),
      change: change,
      changeText: changeText,
    );
  }

  double _firstDouble(
    Map data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value == null) {
        continue;
      }

      final parsed = _toDouble(value);

      if (parsed != 0) {
        return parsed;
      }
    }

    return 0;
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

  void _openWatchlist() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WatchlistScreen(),
      ),
    );
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
              padding:
                  const EdgeInsets.symmetric(
                vertical: 20,
              ),
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(
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
                          fontWeight:
                              FontWeight.w600,
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

                QuickActionsCard(
                  onBrokerTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const UpstoxLoginScreen(),
                      ),
                    );
                  },
                  onWatchlistTap: _openWatchlist,
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}