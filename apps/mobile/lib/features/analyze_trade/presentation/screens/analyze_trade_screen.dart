import 'package:flutter/material.dart';

import '../widgets/symbol_selector.dart';
import '../widgets/option_selector.dart';
import '../widgets/timeframe_selector.dart';

class AnalyzeTradeScreen extends StatefulWidget {
  const AnalyzeTradeScreen({super.key});

  @override
  State<AnalyzeTradeScreen> createState() => _AnalyzeTradeScreenState();
}

class _AnalyzeTradeScreenState extends State<AnalyzeTradeScreen> {
  String symbol = "NIFTY";
  String optionType = "CE";
  String timeframe = "5 Min";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "AI Trade Analyzer",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Analyze your trade before execution",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 25),

            SymbolSelector(
              selected: symbol,
              onChanged: (value) {
                setState(() {
                  symbol = value;
                });
              },
            ),

            const SizedBox(height: 20),

            OptionSelector(
              selected: optionType,
              onChanged: (value) {
                setState(() {
                  optionType = value;
                });
              },
            ),

            const SizedBox(height: 20),

            TimeframeSelector(
              selected: timeframe,
              onChanged: (value) {
                setState(() {
                  timeframe = value;
                });
              },
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: const Text(
                  "Analyze Trade",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {},
              ),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "AI Preview",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 20),

                  Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.indigo),
                      SizedBox(width: 10),
                      Text("Waiting for analysis..."),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
