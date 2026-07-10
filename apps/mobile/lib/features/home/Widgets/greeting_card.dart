import 'package:flutter/material.dart';

class GreetingCard extends StatelessWidget {
  const GreetingCard({super.key});

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: const [

        Text(
          "Good Evening, Sagar 👋",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 6),

        Text(
          "Become Better Than Yesterday",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),

      ],
    );
  }
}