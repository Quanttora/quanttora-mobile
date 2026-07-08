import 'package:flutter/material.dart';

class QuanttoraApp extends StatelessWidget {
  const QuanttoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quanttora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Quanttora'),
        ),
      ),
    );
  }
}