import 'package:flutter/material.dart';

class MarketStatusCard extends StatelessWidget {
  const MarketStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff101828),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xffD4AF37).withValues(alpha: .30),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 14,
            width: 14,
            decoration: const BoxDecoration(
              color: Color(0xff00E676),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            "NSE OPEN",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "09:15 AM",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
    );
  }
}