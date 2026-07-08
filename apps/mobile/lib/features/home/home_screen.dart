import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2746),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.70),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white54,
            size: 18,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              const Center(
                child: Text(
                  "QUANTTORA",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  "Build Better Traders",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.70),
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              buildCard(
                icon: Icons.menu_book_rounded,
                title: "Decision Journal",
                subtitle: "Plan every trade before entry",
              ),

              buildCard(
                icon: Icons.candlestick_chart,
                title: "Market Analysis",
                subtitle: "Understand today's market",
              ),

              buildCard(
                icon: Icons.school_rounded,
                title: "Trading Academy",
                subtitle: "Learn trading with simple lessons",
              ),

              buildCard(
                icon: Icons.track_changes_rounded,
                title: "Today's Focus",
                subtitle: "Protect Capital",
              ),
            ],
          ),
        ),
      ),
    );
  }
}