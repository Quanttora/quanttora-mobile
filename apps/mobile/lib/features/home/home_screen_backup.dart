import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/market_data_service.dart';
import '../../core/widgets/responsive_container.dart';

import 'widgets/ai_trade_score_card.dart';
import 'widgets/home_header.dart';
import 'widgets/market_news_card.dart';
import 'widgets/market_overview_card.dart';
import 'widgets/portfolio_summary_card.dart';
import 'widgets/quick_actions_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MarketDataService _marketService =
      MarketDataService();

  bool _loading = true;

  Timer? _timer;

  late MarketIndex _nifty;
  late MarketIndex _sensex;
  late MarketIndex _bankNifty;

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
      final snapshot =
          await _marketService.fetchSnapshot(
        market: "NIFTY",
      );
            _nifty = MarketIndex(
        name: "NIFTY 50",
        value: snapshot.candles.first.close
            .toStringAsFixed(2),
        change: 0,
        changeText: "LIVE",
      );

      _sensex = MarketIndex(
        name: "SENSEX",
        value: "--",
        change: 0,
        changeText: "LIVE",
      );

      _bankNifty = MarketIndex(
        name: "BANK NIFTY",
        value: "--",
        change: 0,
        changeText: "LIVE",
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
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
              padding: const EdgeInsets.symmetric(
                vertical: 20,
              ),
              children: [
                const HomeHeader(
                  userName: "Sagar",
                ),
                                const PortfolioSummaryCard(
                  totalValue: "₹4,82,350",
                  todayPnL: "+₹6,820",
                  todayPnLPercent: "+1.43%",
                  isProfit: true,
                ),

                const SizedBox(height: 18),

                const AITradeScoreCard(
                  score: 84,
                ),

                const SizedBox(height: 18),

                MarketOverviewCard(
                  nifty: _nifty,
                  sensex: _sensex,
                  bankNifty: _bankNifty,
                ),

                const SizedBox(height: 18),

                const QuickActionsCard(),

                const SizedBox(height: 18),

                MarketNewsCard(
                  news: const [
                    MarketNews(
                      title:
                          "NIFTY closes higher as banking stocks lead the rally.",
                      source: "Moneycontrol",
                      time: "10 min ago",
                      isHighImpact: false,
                    ),
                    MarketNews(
                      title:
                          "RBI policy announcement expected this week.",
                      source: "Economic Times",
                      time: "28 min ago",
                      isHighImpact: true,
                    ),
                    MarketNews(
                      title:
                          "Foreign institutional investors remain net buyers.",
                      source: "CNBC TV18",
                      time: "45 min ago",
                      isHighImpact: false,
                    ),
                  ],
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