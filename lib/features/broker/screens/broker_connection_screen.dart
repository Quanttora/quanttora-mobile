import 'package:flutter/material.dart';

class BrokerConnectionScreen extends StatelessWidget {
  const BrokerConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brokers = [
      Broker(
        "Angel One",
        Icons.account_balance,
        Colors.blue,
      ),
      Broker(
        "Zerodha",
        Icons.show_chart,
        Colors.deepPurple,
      ),
      Broker(
        "Dhan",
        Icons.trending_up,
        Colors.green,
      ),
      Broker(
        "Upstox",
        Icons.bar_chart,
        Colors.orange,
      ),
      Broker(
        "Groww",
        Icons.auto_graph,
        Colors.teal,
      ),
      Broker(
        "Fyers",
        Icons.candlestick_chart,
        Colors.red,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Connect Broker"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose your broker",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Connect your broker once to unlock AI-powered trade analysis.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: ListView.separated(
                itemCount: brokers.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final broker = brokers[index];

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                      side: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            broker.color.withValues(alpha: 0.15),
                        child: Icon(
                          broker.icon,
                          color: broker.color,
                        ),
                      ),
                      title: Text(
                        broker.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text(
                        "Secure OAuth Connection",
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              "${broker.name} integration coming soon.",
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Broker {
  final String name;
  final IconData icon;
  final Color color;

  Broker(
    this.name,
    this.icon,
    this.color,
  );
}