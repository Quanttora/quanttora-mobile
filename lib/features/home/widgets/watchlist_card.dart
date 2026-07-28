import 'package:flutter/material.dart';

class WatchlistCard extends StatelessWidget {
  const WatchlistCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "⭐ Watchlist",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),

          _item(
            symbol: "RELIANCE",
            price: "₹1,523.60",
            change: "+1.42%",
            positive: true,
          ),

          const Divider(),

          _item(
            symbol: "TCS",
            price: "₹4,128.40",
            change: "-0.34%",
            positive: false,
          ),

          const Divider(),

          _item(
            symbol: "HDFCBANK",
            price: "₹1,845.10",
            change: "+0.81%",
            positive: true,
          ),
        ],
      ),
    );
  }

  Widget _item({
    required String symbol,
    required String price,
    required String change,
    required bool positive,
  }) {
    final color = positive ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              symbol,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            change,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}