import 'package:flutter/material.dart';
import 'package:mobile/features/broker/broker_service.dart';
import 'package:mobile/features/broker/widgets/broker_status_card.dart';

import '../../core/decision_engine/decision_engine.dart';
import '../trade_analysis/screens/trade_analysis_screen.dart';

import 'widgets/greeting_card.dart';
import 'widgets/decision_score_card.dart';
import 'widgets/cards/market_pulse_card.dart';
import 'widgets/cards/today_mission_card.dart';
import 'widgets/cards/ai_coach_card.dart';
import 'widgets/cards/academy_card.dart';
import 'widgets/cards/quick_action_card.dart';

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

  @override
  void initState() {
    super.initState();
    _loadBroker();
  }

  Future<void> _loadBroker() async {
    try {
      final data = await _brokerService.getBrokerStatus();
print("BROKER STATUS: $data");

      setState(() {
        _connected = data['connected'] ?? false;

        if (_connected) {
          _broker = data['broker'] ?? '';
          _userName = data['userName'] ?? '';
          _email = data['email'] ?? '';
          _userId = data['userId'] ?? '';
        }

        _loading = false;
      });
    } catch (_) {
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

  final data = await _brokerService.waitForConnection();

  setState(() {
    _connected = true;
    _broker = data['broker'] ?? '';
    _userName = data['userName'] ?? '';
    _email = data['email'] ?? '';
    _userId = data['userId'] ?? '';
    _loading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    final result = DecisionEngine.demoResult();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadBroker,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GreetingCard(),

                const SizedBox(height: 20),

                if (_loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  BrokerStatusCard(
                    connected: _connected,
                    broker: _broker,
                    userName: _userName,
                    email: _email,
                    userId: _userId,
                    onConnect: _connectBroker,
                  ),

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
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 220,
        height: 60,
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF155EEF),
          elevation: 8,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TradeAnalysisScreen(),
              ),
            );
          },
          icon: const Icon(Icons.analytics_rounded),
          label: const Text(
            "ANALYZE TRADE",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 75,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _NavItem(
              icon: Icons.home_rounded,
              title: "Home",
              selected: true,
            ),
            _NavItem(
              icon: Icons.show_chart_rounded,
              title: "Markets",
            ),
            SizedBox(width: 50),
            _NavItem(
              icon: Icons.school_rounded,
              title: "Academy",
            ),
            _NavItem(
              icon: Icons.person_rounded,
              title: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;

  const _NavItem({
    required this.icon,
    required this.title,
    this.selected = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.blue : Colors.grey;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight:
                selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}