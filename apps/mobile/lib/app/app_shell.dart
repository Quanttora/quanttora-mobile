import 'package:flutter/material.dart';

import 'package:mobile/features/home/home_screen.dart';
import 'package:mobile/features/strategy/presentation/screens/strategy_screen.dart';
import 'package:mobile/features/trade_analysis/screens/trade_analysis_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = const [
      HomeScreen(),
      StrategyScreen(),
      AIScreen(),
      ProfileScreen(),
    ];
  }

  void _changeTab(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,

      floatingActionButton: Container(
        height: 62,
        constraints: const BoxConstraints(
          maxWidth: 280,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF155EEF)
                  .withValues(alpha: .35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),

        child: FloatingActionButton.extended(
          heroTag: "analyze",

          elevation: 0,

          backgroundColor: const Color(0xFF155EEF),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const TradeAnalysisScreen(),
              ),
            );
          },

          icon: const Icon(
            Icons.auto_awesome_rounded,
            size: 24,
          ),

          label: const Text(
            "Analyze Trade",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
            bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16,
          ),
          height: 74,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_rounded,
                  title: "Home",
                  selected: _selectedIndex == 0,
                  onTap: () => _changeTab(0),
                ),
              ),

              Expanded(
                child: _NavItem(
                  icon: Icons.auto_graph_rounded,
                  title: "Strategy",
                  selected: _selectedIndex == 1,
                  onTap: () => _changeTab(1),
                ),
              ),

              const SizedBox(width: 90),

              Expanded(
                child: _NavItem(
                  icon: Icons.smart_toy_rounded,
                  title: "AI",
                  selected: _selectedIndex == 2,
                  onTap: () => _changeTab(2),
                ),
              ),

              Expanded(
                child: _NavItem(
                  icon: Icons.person_rounded,
                  title: "Profile",
                  selected: _selectedIndex == 3,
                  onTap: () => _changeTab(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? const Color(0xFF155EEF)
        : Colors.grey.shade500;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF155EEF)
                      .withValues(alpha: .10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: selected
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
class AIScreen extends StatelessWidget {
  const AIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        title: const Text("Quanttora AI"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 520,
          ),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircleAvatar(
                radius: 38,
                backgroundColor: Color(0xFFEAF2FF),
                child: Icon(
                  Icons.smart_toy_rounded,
                  size: 42,
                  color: Color(0xFF155EEF),
                ),
              ),

              SizedBox(height: 20),

              Text(
                "Quanttora AI",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10),

              Text(
                "AI Scanner, Trade Assistant,\nMarket Insights and Decision Engine\nwill appear here.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 520,
          ),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
                    child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircleAvatar(
                radius: 38,
                backgroundColor: Color(0xFFEAF2FF),
                child: Icon(
                  Icons.person_rounded,
                  size: 42,
                  color: Color(0xFF155EEF),
                ),
              ),

              SizedBox(height: 20),

              Text(
                "Profile",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10),

              Text(
                "Account, Broker Connections,\nSubscription and Settings\nwill appear here.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}