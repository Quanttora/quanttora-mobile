import 'package:flutter/material.dart';
import 'package:mobile/app/app_shell.dart';

import '../core/theme/app_theme.dart';

class QuanttoraApp extends StatelessWidget {
  const QuanttoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quanttora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppShell(),
    );
  }
}