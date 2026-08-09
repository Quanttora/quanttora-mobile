import 'package:flutter/material.dart';

import '../broker_service.dart';
import 'broker_connected_screen.dart';

class UpstoxLoginScreen extends StatefulWidget {
  const UpstoxLoginScreen({super.key});

  @override
  State<UpstoxLoginScreen> createState() => _UpstoxLoginScreenState();
}

class _UpstoxLoginScreenState extends State<UpstoxLoginScreen> {
  final BrokerService _brokerService = BrokerService();

  bool _loading = false;

  Future<void> _connect() async {
    if (_loading) return;

    setState(() {
      _loading = true;
    });

    try {
      await _brokerService.connectBroker();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Upstox login opened. Complete the login in your browser.',
          ),
        ),
      );

      final dashboard = await _brokerService.waitForConnection();

      if (!mounted) return;

      final broker = dashboard['broker']?.toString() ?? 'Upstox';

      final userData = dashboard['user'] is Map
          ? dashboard['user'] as Map
          : <dynamic, dynamic>{};

      final name =
          dashboard['userName']?.toString() ??
          userData['name']?.toString() ??
          'Connected User';

      final email =
          dashboard['email']?.toString() ??
          userData['email']?.toString() ??
          '';

      final userId =
          dashboard['userId']?.toString() ??
          userData['userId']?.toString() ??
          '';

      final availableMargin = _toDouble(
        dashboard['availableMargin'],
      );

      final usedMargin = _toDouble(
        dashboard['usedMargin'],
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BrokerConnectedScreen(
            broker: broker,
            name: name,
            email: email,
            userId: userId,
            availableMargin: availableMargin,
            usedMargin: usedMargin,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Broker connection failed: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Broker'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.account_balance_rounded,
                    size: 70,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Connect Your Broker',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Connect your Upstox account to access live market data, positions and trading features.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _loading ? null : _connect,
                      icon: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.login_rounded),
                      label: Text(
                        _loading
                            ? 'Waiting for Upstox...'
                            : 'Connect Upstox',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}