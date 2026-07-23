import 'package:flutter/material.dart';
import 'package:mobile/features/broker/broker_service.dart';
import 'package:mobile/features/broker/widgets/broker_status_card.dart';

import 'package:mobile/core/decision_engine/decision_engine.dart';

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

  double _availableMargin = 0;
  double _usedMargin = 0;

  @override
  void initState() {
    super.initState();
    _loadBroker();
  }

  Future<void> _loadBroker() async {
    try {
      final data = await _brokerService.getBrokerStatus();
      final funds = await _brokerService.getFunds();

      print("BROKER STATUS: $data");

      setState(() {
        _connected = data['connected'] ?? false;

        if (_connected) {
          _broker = data['broker'] ?? '';
          _userName = data['userName'] ?? '';
          _email = data['email'] ?? '';
          _userId = data['userId'] ?? '';

          _availableMargin =
              (funds['data']['equity']['available_margin'] ?? 0)
                  .toDouble();

          _usedMargin =
              (funds['data']['equity']['used_margin'] ?? 0)
                  .toDouble();
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
    final funds = await _brokerService.getFunds();

    setState(() {
      _connected = true;
      _broker = data['broker'] ?? '';
      _userName = data['userName'] ?? '';
      _email = data['email'] ?? '';
      _userId = data['userId'] ?? '';

      _availableMargin =
          (funds['data']['equity']['available_margin'] ?? 0)
              .toDouble();

      _usedMargin =
          (funds['data']['equity']['used_margin'] ?? 0)
              .toDouble();

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
                    availableMargin: _availableMargin,
                    usedMargin: _usedMargin,
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
          );
  }
}