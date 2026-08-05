import 'package:flutter/material.dart';

import '../../session/services/session_manager.dart';
import '../../trading_mode/screens/trading_mode_screen.dart';

class InstrumentSelectionScreen extends StatefulWidget {
  const InstrumentSelectionScreen({super.key});

  @override
  State<InstrumentSelectionScreen> createState() =>
      _InstrumentSelectionScreenState();
}

class _InstrumentSelectionScreenState extends State<InstrumentSelectionScreen> {
  final List<String> instruments = [
    "NIFTY 50",
    "BANK NIFTY",
    "SENSEX",
    "FINNIFTY",
    "MIDCPNIFTY",
  ];

  String selectedInstrument = "NIFTY 50";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Instrument"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose Trading Instrument",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "Select the market you want Quanttora AI to analyze.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: ListView.builder(
                itemCount: instruments.length,
                itemBuilder: (context, index) {
                  final instrument = instruments[index];
                  final selected = instrument == selectedInstrument;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        setState(() {
                          selectedInstrument = instrument;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF2563EB)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF2563EB)
                                : Colors.grey.shade300,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.show_chart_rounded,
                              color: selected ? Colors.white : Colors.blue,
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Text(
                                instrument,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: selected ? Colors.white : Colors.black,
                                ),
                              ),
                            ),

                            if (selected)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  SessionManager.instance.updateInstrument(selectedInstrument);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TradingModeScreen(),
                    ),
                  );
                },
                child: const Text(
                  "CONTINUE",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
