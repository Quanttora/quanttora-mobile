import 'package:flutter/material.dart';

class TradingModeScreen extends StatefulWidget {
  const TradingModeScreen({super.key});

  @override
  State<TradingModeScreen> createState() => _TradingModeScreenState();
}

class _TradingModeScreenState extends State<TradingModeScreen> {
  String selectedMode = "Scalping";

  final List<_TradingMode> modes = [
    _TradingMode(
      title: "Scalping",
      subtitle: "Ultra fast trades (1-5 min)",
      icon: Icons.flash_on_rounded,
      color: Colors.orange,
    ),
    _TradingMode(
      title: "Intraday",
      subtitle: "Trades closed the same day",
      icon: Icons.show_chart_rounded,
      color: Colors.blue,
    ),
    _TradingMode(
      title: "Swing",
      subtitle: "Hold for days to weeks",
      icon: Icons.trending_up_rounded,
      color: Colors.green,
    ),
    _TradingMode(
      title: "Long Term",
      subtitle: "Invest for months & years",
      icon: Icons.account_balance_rounded,
      color: Colors.deepPurple,
    ),
    _TradingMode(
      title: "Hedge",
      subtitle: "Options hedge & protection",
      icon: Icons.shield_rounded,
      color: Colors.red,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trading Mode"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How do you trade?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Quanttora AI adapts its analysis based on your trading style.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: ListView.builder(
                itemCount: modes.length,
                itemBuilder: (context, index) {
                  final mode = modes[index];
                  final selected = mode.title == selectedMode;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        setState(() {
                          selectedMode = mode.title;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: selected
                              ? mode.color
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? mode.color
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
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: selected
                                  ? Colors.white
                                  : mode.color.withValues(alpha: 0.15),
                              child: Icon(
                                mode.icon,
                                color: selected
                                    ? mode.color
                                    : mode.color,
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mode.title,
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: selected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    mode.subtitle,
                                    style: TextStyle(
                                      color: selected
                                          ? Colors.white70
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (selected)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 28,
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
                onPressed: () {},
                child: const Text(
                  "CONTINUE",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TradingMode {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _TradingMode({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}