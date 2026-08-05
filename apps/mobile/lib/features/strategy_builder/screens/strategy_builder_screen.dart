import 'package:flutter/material.dart';

class StrategyBuilderScreen extends StatefulWidget {
  const StrategyBuilderScreen({super.key});

  @override
  State<StrategyBuilderScreen> createState() => _StrategyBuilderScreenState();
}

class _StrategyBuilderScreenState extends State<StrategyBuilderScreen> {
  final TextEditingController strategyController = TextEditingController();

  String selectedMarket = "NIFTY 50";

  String selectedMode = "Scalping";

  final List<String> selectedIndicators = [];

  final List<String> markets = [
    "NIFTY 50",
    "BANKNIFTY",
    "SENSEX",
    "FINNIFTY",
    "MIDCPNIFTY",
    "STOCKS",
  ];

  final List<String> tradingModes = [
    "Scalping",
    "Intraday",
    "Swing",
    "Long Term",
    "Hedge",
  ];

  final List<IndicatorCardData> indicators = [
    IndicatorCardData("EMA", "Trend"),
    IndicatorCardData("VWAP", "Price"),
    IndicatorCardData("ADX", "Trend Strength"),
    IndicatorCardData("RSI", "Momentum"),
    IndicatorCardData("Volume", "Volume"),
    IndicatorCardData("MACD", "Momentum"),
    IndicatorCardData("SuperTrend", "Trend"),
    IndicatorCardData("ATR", "Volatility"),
    IndicatorCardData("Bollinger", "Volatility"),
    IndicatorCardData("Stochastic", "Momentum"),
    IndicatorCardData("CCI", "Momentum"),
    IndicatorCardData("ROC", "Momentum"),
    IndicatorCardData("MFI", "Volume"),
    IndicatorCardData("OBV", "Volume"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Strategy Builder"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create Your Strategy",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "Build your own trading blueprint.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const SizedBox(height: 30),

            const Text(
              "Strategy Name",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: strategyController,
              decoration: InputDecoration(
                hintText: "My Scalping Strategy",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text("Market", style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: markets.map((market) {
                final selected = market == selectedMarket;

                return ChoiceChip(
                  label: Text(market),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      selectedMarket = market;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            const Text(
              "Trading Mode",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: tradingModes.map((mode) {
                final selected = mode == selectedMode;

                return ChoiceChip(
                  label: Text(mode),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      selectedMode = mode;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            const Text(
              "Indicator Library",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: indicators.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.55,
              ),
              itemBuilder: (context, index) {
                final item = indicators[index];

                final selected = selectedIndicators.contains(item.name);

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    setState(() {
                      if (selected) {
                        selectedIndicators.remove(item.name);
                      } else {
                        selectedIndicators.add(item.name);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selected ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected ? Colors.blue : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: selected ? Colors.white : Colors.black,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          item.category,
                          style: TextStyle(
                            color: selected ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            const Text(
              "Risk Management",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 18),

            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Risk Per Trade (%)",
                hintText: "1",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Minimum Risk Reward",
                hintText: "1 : 3",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Maximum Daily Loss",
                hintText: "3000",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Maximum Trades Per Day",
                hintText: "3",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Strategy Summary",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),

                  const SizedBox(height: 14),

                  Text("Market : $selectedMarket"),

                  const SizedBox(height: 6),

                  Text("Trading Mode : $selectedMode"),

                  const SizedBox(height: 6),

                  Text("Indicators Selected : ${selectedIndicators.length}"),

                  const SizedBox(height: 14),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedIndicators
                        .map((e) => Chip(label: Text(e)))
                        .toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text(
                  "SAVE STRATEGY",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class IndicatorCardData {
  final String name;
  final String category;

  const IndicatorCardData(this.name, this.category);
}
