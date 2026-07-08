import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/q_button.dart';

class QuanttoraApp extends StatelessWidget {
  const QuanttoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quanttora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: QButton(
              text: 'Start Journal',
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
  }
}