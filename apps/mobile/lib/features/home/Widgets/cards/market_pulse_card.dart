import 'package:flutter/material.dart';

class MarketPulseCard extends StatelessWidget {
  const MarketPulseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xff111827),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.candlestick_chart,
                color: Colors.greenAccent,
                size: 30,
              ),
              SizedBox(width: 12),
              Text(
                "Market Pulse",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            "Live market overview",
            style: TextStyle(color: Colors.white60),
          ),

          const SizedBox(height: 24),

          const Row(
            children: [
              Expanded(
                child: _PulseTile(
                  title: "NIFTY 50",
                  value: "25,185",
                  change: "+182",
                  color: Colors.green,
                  icon: Icons.trending_up,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _PulseTile(
                  title: "BANKNIFTY",
                  value: "57,210",
                  change: "+98",
                  color: Colors.green,
                  icon: Icons.account_balance,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Row(
            children: [
              Expanded(
                child: _PulseTile(
                  title: "VIX",
                  value: "11.24",
                  change: "-2.4%",
                  color: Colors.orange,
                  icon: Icons.warning_amber,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _PulseTile(
                  title: "FII Flow",
                  value: "₹860 Cr",
                  change: "BUY",
                  color: Colors.lightBlue,
                  icon: Icons.account_balance_wallet,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.green.withValues(alpha: .30)),
            ),
            child: const Row(
              children: [
                Icon(Icons.psychology_alt, color: Colors.greenAccent),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "AI Market Bias : BULLISH\nWait for pullback confirmation before entering.",
                    style: TextStyle(color: Colors.white, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseTile extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final Color color;
  final IconData icon;

  const _PulseTile({
    required this.title,
    required this.value,
    required this.change,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff1F2937),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            change,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
