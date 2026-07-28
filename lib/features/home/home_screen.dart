import 'package:flutter/material.dart';

import 'package:mobile/features/broker/broker_service.dart';

import 'widgets/common/section_title.dart';

import 'widgets/sections/ai_section.dart';
import 'widgets/sections/broker_section.dart';
import 'widgets/sections/holdings_section.dart';
import 'widgets/sections/home_header.dart';
import 'widgets/sections/market_indices_section.dart';
import 'widgets/sections/news_section.dart';
import 'widgets/sections/orders_section.dart';
import 'widgets/sections/portfolio_section.dart';
import 'widgets/sections/positions_section.dart';
import 'widgets/sections/trades_section.dart';
import 'widgets/sections/watchlist_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BrokerService _brokerService = BrokerService();

  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _marketIndices;
  Map<String, dynamic>? _portfolio;
  Map<String, dynamic>? _brokerProfile;
  Map<String, dynamic>? _aiData;

  List<dynamic> _holdings = [];
  List<dynamic> _positions = [];
  List<dynamic> _orders = [];
  List<dynamic> _trades = [];
  List<dynamic> _watchlist = [];
  List<dynamic> _news = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    final dashboard =
        await _brokerService.getDashboard();

    _marketIndices =
        await _brokerService.getMarketIndices();

    _portfolio = {
      "availableMargin": ((dashboard["funds"]?["available_margin"] ?? 0)
              as num)
          .toDouble(),
      "usedMargin":
          ((dashboard["funds"]?["used_margin"] ?? 0) as num)
              .toDouble(),
      "broker": "Upstox",
      "connected": dashboard["connected"] ?? false,
    };

    _brokerProfile = {
      "user_name":
          dashboard["profile"]?["user_name"] ?? "--",
      "email":
          dashboard["profile"]?["email"] ?? "--",
      "user_id":
          dashboard["profile"]?["user_id"] ?? "--",
    };

    _holdings = await _brokerService.getHoldings();
    _positions = await _brokerService.getPositions();
    _orders = await _brokerService.getOrders();
    _trades = await _brokerService.getTrades();

    _watchlist = [];
    _news = [];

    _aiData = {
      "score": 82,
      "trend": "Bullish",
      "confidence": 91.4,
      "message":
          "Momentum remains positive. Prefer high-quality setups and maintain disciplined risk management.",
    };
  } catch (e) {
    _error = e.toString();
  }

  if (!mounted) return;

  setState(() {
    _loading = false;
  });
}

  @override
  Widget build(BuildContext context) {
        return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeHeader(),

                const SizedBox(height: 24),

                const SectionTitle(
                  title: "Market Indices",
                ),

                const SizedBox(height: 12),

                MarketIndicesSection(
                  loading: _loading,
                  error: _error,
                  data: _marketIndices,
                ),

                const SizedBox(height: 24),

                const SectionTitle(
                  title: "Broker Account",
                ),

                const SizedBox(height: 12),

                BrokerSection(
                  loading: _loading,
                  connected: _brokerProfile != null,
                  broker: "Upstox",
                  userName:
                      _brokerProfile?["user_name"] ?? "--",
                  email:
                      _brokerProfile?["email"] ?? "--",
                  userId:
                      _brokerProfile?["user_id"] ?? "--",
                  availableMargin:
                      ((_portfolio?["availableMargin"] ?? 0)
                              as num)
                          .toDouble(),
                  usedMargin:
                      ((_portfolio?["usedMargin"] ?? 0)
                              as num)
                          .toDouble(),
                  onConnect: () {},
                ),

                const SizedBox(height: 24),

                const SectionTitle(
                  title: "Portfolio",
                ),

                const SizedBox(height: 12),

                PortfolioSection(
                  loading: _loading,
                  error: _error,
                  portfolio: _portfolio,
                ),

                const SizedBox(height: 24),

                const SectionTitle(
                  title: "AI Coach",
                ),

                const SizedBox(height: 12),

                AiSection(
                  loading: _loading,
                  error: _error,
                  aiData: _aiData,
                ),

                const SizedBox(height: 24),
                                const SectionTitle(
                  title: "Holdings",
                ),

                const SizedBox(height: 12),

                HoldingsSection(
                  loading: _loading,
                  error: _error,
                  holdings: _holdings,
                ),

                const SizedBox(height: 24),

                const SectionTitle(
                  title: "Open Positions",
                ),

                const SizedBox(height: 12),

                PositionsSection(
                  loading: _loading,
                  error: _error,
                  positions: _positions,
                ),

                const SizedBox(height: 24),

                const SectionTitle(
                  title: "Today's Orders",
                ),

                const SizedBox(height: 12),

                OrdersSection(
                  loading: _loading,
                  error: _error,
                  orders: _orders,
                ),

                const SizedBox(height: 24),

                const SectionTitle(
                  title: "Today's Trades",
                ),

                const SizedBox(height: 12),

                TradesSection(
                  loading: _loading,
                  error: _error,
                  trades: _trades,
                ),

                const SizedBox(height: 24),

                const SectionTitle(
                  title: "Watchlist",
                ),

                const SizedBox(height: 12),

                WatchlistSection(
                  loading: _loading,
                  error: _error,
                  watchlist: _watchlist,
                ),

                const SizedBox(height: 24),

                const SectionTitle(
                  title: "Market News",
                ),

                const SizedBox(height: 12),

                NewsSection(
                  loading: _loading,
                  error: _error,
                  news: _news,
                ),

                const SizedBox(height: 32),
                              ],
            ),
          ),
        ),
      ),
    );
  }
}