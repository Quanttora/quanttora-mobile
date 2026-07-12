import '../decision_engine/decision_engine_screen.dart';
import 'package:flutter/material.dart';

import 'widgets/greeting_card.dart';
import 'widgets/decision_score_card.dart';
import 'widgets/cards/market_pulse_card.dart';
import 'widgets/cards/today_mission_card.dart';
import 'widgets/cards/ai_coach_card.dart';
import 'widgets/cards/academy_card.dart';
import 'widgets/cards/quick_action_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [

              GreetingCard(),

              SizedBox(height: 20),

              DecisionScoreCard(),

              SizedBox(height: 20),

              MarketPulseCard(),

              SizedBox(height: 20),

              TodayMissionCard(),

              SizedBox(height: 20),

              AICoachCard(),

              SizedBox(height: 20),

              AcademyCard(),

              SizedBox(height: 20),

              QuickActionCard(),

              SizedBox(height: 120),

            ],
          ),
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      floatingActionButton: SizedBox(
        width: 190,
        height: 60,
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF2563EB),
          elevation: 8,
          onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const DecisionEngineScreen(),
    ),
  );
},
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text(
            "EXECUTE",
            style: TextStyle(
              fontSize: 18,
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