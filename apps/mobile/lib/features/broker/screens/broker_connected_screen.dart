import 'package:flutter/material.dart';

class BrokerConnectedScreen extends StatelessWidget {
  final String broker;
  final String name;
  final String email;

  const BrokerConnectedScreen({
    super.key,
    required this.broker,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Broker Connected"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified,
                    color: Colors.green,
                    size: 70,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Broker Connected",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ListTile(
                    leading: const Icon(Icons.account_balance),
                    title: const Text("Broker"),
                    subtitle: Text(broker),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("User"),
                    subtitle: Text(name),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text("Email"),
                    subtitle: Text(email),
                  ),
                  const ListTile(
                    leading: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    title: Text("Status"),
                    subtitle: Text("CONNECTED"),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Continue"),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}