import 'package:flutter/material.dart';

import '../../session/services/session_manager.dart';
import 'ai_analysis_screen.dart';

class TradeAnalysisScreen extends StatefulWidget {
  const TradeAnalysisScreen({super.key});

  @override
  State<TradeAnalysisScreen> createState() => _TradeAnalysisScreenState();
}

class _TradeAnalysisScreenState extends State<TradeAnalysisScreen> {
  static const List<String> _defaultMarkets = [
    "NIFTY 50",
    "BANKNIFTY",
    "SENSEX",
    "BANKEX",
    "FINNIFTY",
    "MIDCAP SELECT",
    "NEXT 50",
    "STOCK",
  ];

  String selectedMarket = "";
  String selectedDirection = "CALL";

  List<String> get _strategyMarkets {
    final instruments = SessionManager.instance.session.strategyInstruments;

    if (instruments.isEmpty) {
      return _defaultMarkets;
    }

    return instruments;
  }

  @override
  void initState() {
    super.initState();

    final markets = _strategyMarkets;

    if (markets.isNotEmpty) {
      selectedMarket = markets.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionManager.instance.session;
    final markets = _strategyMarkets;

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Trade Analysis",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (session.strategy.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffEAF1FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_graph_rounded,
                    color: Color(0xff155EEF),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Selected Strategy",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.strategy,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (session.strategyTimeframe.isNotEmpty)
                          Text(
                            "Timeframe: "
                            "${session.strategyTimeframe}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          const Text(
            "Select Market",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text(
            "Only instruments allowed by your selected strategy "
            "are available.",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 20),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: markets.map((market) {
              return ChoiceChip(
                label: Text(market),
                selected: selectedMarket == market,
                selectedColor: const Color(0xff155EEF),
                labelStyle: TextStyle(
                  color: selectedMarket == market ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (_) {
                  setState(() {
                    selectedMarket = market;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 35),

          const Text(
            "Trade Direction",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(child: directionButton("CALL")),
              const SizedBox(width: 15),
              Expanded(child: directionButton("PUT")),
            ],
          ),

          const SizedBox(height: 40),

          SizedBox(
            height: 60,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff155EEF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: selectedMarket.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AIAnalysisScreen(
                            market: selectedMarket,
                            direction: selectedDirection,
                          ),
                        ),
                      );
                    },
              label: const Text(
                "START AI ANALYSIS",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget directionButton(String value) {
    final selected = selectedDirection == value;

    return SizedBox(
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? const Color(0xff155EEF) : Colors.white,
          foregroundColor: selected ? Colors.white : Colors.black,
        ),
        onPressed: () {
          setState(() {
            selectedDirection = value;
          });
        },
        child: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
    );
  }
}
