import 'package:flutter/material.dart';

class HeroAiCard extends StatelessWidget {
  const HeroAiCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffD4AF37), Color(0xffA87D18)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55D4AF37),
            blurRadius: 30,
            spreadRadius: 2,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: Colors.black),
              SizedBox(width: 8),
              Text(
                "QUANTTORA AI",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            "Analyze Before\nYou Trade",
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Validate your strategy with AI before risking your capital.",
            style: TextStyle(color: Colors.black87, fontSize: 15),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {},
              icon: const Icon(Icons.analytics_outlined),
              label: const Text(
                "Analyze Trade",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
