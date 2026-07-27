import 'package:flutter/material.dart';
import 'package:mobile/core/decision_engine/decision_engine.dart';
import 'package:mobile/features/broker/broker_service.dart';
import 'package:mobile/features/broker/widgets/broker_status_card.dart';

import 'widgets/greeting_card.dart';
import 'widgets/decision_score_card.dart';

import 'widgets/cards/portfolio_summary_card.dart';
import 'widgets/cards/holdings_card.dart';
import 'widgets/cards/positions_card.dart';
import 'widgets/cards/orders_card.dart';
import 'widgets/cards/trades_card.dart';

import 'widgets/cards/academy_card.dart';
import 'widgets/cards/ai_coach_card.dart';
import 'widgets/cards/market_pulse_card.dart';
import 'widgets/cards/quick_action_card.dart';
import 'widgets/cards/today_mission_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BrokerService _brokerService = BrokerService();

  bool _loading = true;
  bool _connected = false;

  String _broker = '';
  String _userName = '';
  String _email = '';
  String _userId = '';

  double _availableMargin = 0;
  double _usedMargin = 0;

  List<dynamic> _holdings = [];
  List<dynamic> _positions = [];
  List<dynamic> _orders = [];
  List<dynamic> _trades = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final dashboard = await _brokerService.getDashboard();

      final user = dashboard["user"] ?? {};
      final funds = dashboard["funds"] ?? {};
      final equity = funds["data"]?["equity"] ?? {};

      setState(() {
        _connected = dashboard["connected"] ?? false;

        _broker = dashboard["broker"] ?? "";

        _userName = user["name"] ?? "";
        _email = user["email"] ?? "";
        _userId = user["userId"] ?? "";

        _availableMargin =
            ((equity["available_margin"] ?? 0) as num).toDouble();

        _usedMargin =
            ((equity["used_margin"] ?? 0) as num).toDouble();

        _holdings =
            (dashboard["holdings"]?["data"] as List?) ?? [];

        _positions =
            (dashboard["positions"]?["data"] as List?) ?? [];

        _orders =
            (dashboard["orders"]?["data"] as List?) ?? [];

        _trades =
            (dashboard["trades"]?["data"] as List?) ?? [];

        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _connectBroker() async {
    await _brokerService.connectBroker();

    setState(() {
      _loading = true;
    });

    await Future.delayed(
      const Duration(seconds: 2),
    );

    await _loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final result = DecisionEngine.demoResult();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboard,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const GreetingCard(),

                const SizedBox(height: 20),

                if (_loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child:
                          CircularProgressIndicator(),
                    ),
                  )
                else ...[
                  BrokerStatusCard(
                    connected: _connected,
                    broker: _broker,
                    userName: _userName,
                    email: _email,
                    userId: _userId,
                    availableMargin:
                        _availableMargin,
                    usedMargin: _usedMargin,
                    onConnect: _connectBroker,
                  ),

                  const SizedBox(height: 20),

                  PortfolioSummaryCard(
                    connected: _connected,
                    broker: _broker,
                    availableMargin:
                        _availableMargin,
                    usedMargin: _usedMargin,
                  ),

                  const SizedBox(height: 20),

                  HoldingsCard(
                    holdings: _holdings,
                  ),

                  const SizedBox(height: 20),
                                    PositionsCard(
                    positions: _positions,
                  ),

                  const SizedBox(height: 20),

                  OrdersCard(
                    orders: _orders,
                  ),

                  const SizedBox(height: 20),

                  TradesCard(
                    trades: _trades,
                  ),
                ],

                const SizedBox(height: 20),

                DecisionScoreCard(
                  result: result,
                ),

                const SizedBox(height: 20),

                const MarketPulseCard(),

                const SizedBox(height: 20),

                const TodayMissionCard(),

                const SizedBox(height: 20),

                const AICoachCard(),

                const SizedBox(height: 20),

                const AcademyCard(),

                const SizedBox(height: 20),

                const QuickActionCard(),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }
}