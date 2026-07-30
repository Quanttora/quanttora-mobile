import 'package:flutter/material.dart';

import '../../core/services/market_data_service.dart';
import 'widgets/ai_trade_score_card.dart';
import 'widgets/home_header.dart';
import 'widgets/market_news_card.dart';
import 'widgets/market_overview_card.dart';
import 'widgets/portfolio_summary_card.dart';
import 'widgets/quick_actions_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MarketDataService _marketService = MarketDataService();

  bool _loading = true;

  late MarketIndex _nifty;
  late MarketIndex _sensex;
  late MarketIndex _bankNifty;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    await _marketService.fetchSnapshot(
      market: "NIFTY",
    );

    _nifty = const MarketIndex(
      name: "NIFTY 50",
      value: "25,184.20",
      change: 184.25,
      changeText: "184.25 (0.74%)",
    );

    _sensex = const MarketIndex(
      name: "SENSEX",
      value: "82,611.08",
      change: 536.70,
      changeText: "536.70 (0.65%)",
    );

    _bankNifty = const MarketIndex(
      name: "BANK NIFTY",
      value: "57,228.15",
      change: -112.40,
      changeText: "112.40 (0.20%)",
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
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
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 12),

              const HomeHeader(
                userName: "Sagar",
              ),

              const SizedBox(height: 20),

              const PortfolioSummaryCard(
                totalValue: "₹4,82,350",
                todayPnL: "+₹6,820",
                todayPnLPercent: "+1.43%",
                isProfit: true,
              ),

              const SizedBox(height: 20),

              const AITradeScoreCard(
                score: 84,
              ),

              const SizedBox(height: 20),

              MarketOverviewCard(
                nifty: _nifty,
                sensex: _sensex,
                bankNifty: _bankNifty,
              ),

              const SizedBox(height: 20),

              const QuickActionsCard(),

              const SizedBox(height: 20),

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

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}