import 'package:flutter/material.dart';

import '../../instrument/screens/instrument_selection_screen.dart';
import '../../session/services/session_manager.dart';

class BrokerConnectionScreen extends StatelessWidget {
  const BrokerConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brokers = [
      Broker("Angel One", Icons.account_balance, Colors.blue),
      Broker("Zerodha", Icons.show_chart, Colors.deepPurple),
      Broker("Dhan", Icons.trending_up, Colors.green),
      Broker("Upstox", Icons.bar_chart, Colors.orange),
      Broker("Groww", Icons.auto_graph, Colors.teal),
      Broker("Fyers", Icons.candlestick_chart, Colors.red),
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
              "Choose your Broker",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Select your broker to continue.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
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
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
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
                        "Secure Connection",
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                      ),
                      onTap: () {
                        SessionManager.instance
                            .updateBroker(broker.name);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const InstrumentSelectionScreen(),
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

  const Broker(
    this.name,
    this.icon,
    this.color,
  );
}