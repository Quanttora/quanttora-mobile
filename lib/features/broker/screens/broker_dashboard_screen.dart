import 'package:flutter/material.dart';

import '../broker_service.dart';
import 'holdings_screen.dart';
import 'positions_screen.dart';
import 'orders_screen.dart';
import 'trades_screen.dart';

class BrokerDashboardScreen extends StatefulWidget {
  const BrokerDashboardScreen({super.key});

  @override
  State<BrokerDashboardScreen> createState() =>
      _BrokerDashboardScreenState();
}

class _BrokerDashboardScreenState extends State<BrokerDashboardScreen> {
  final BrokerService _brokerService = BrokerService();

  bool _loading = true;
  String? _error;

  Map<String, dynamic> _dashboard = {};

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dashboard = await _brokerService.getDashboard();

      if (!mounted) return;

      setState(() {
        _dashboard = dashboard;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  List _extractList(dynamic value) {
    if (value is Map && value['data'] is List) {
      return value['data'];
    }

    if (value is List) {
      return value;
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Broker Dashboard'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 50,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load broker dashboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _loadDashboard,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final broker = _dashboard['broker']?.toString() ?? 'Upstox';

    final user = _dashboard['user'] is Map
        ? _dashboard['user'] as Map
        : <dynamic, dynamic>{};

    final name = user['name']?.toString() ?? 'User';

    final availableMargin = _toDouble(
      _dashboard['availableMargin'],
    );

    final usedMargin = _toDouble(
      _dashboard['usedMargin'],
    );

    final holdings = _extractList(
      _dashboard['holdings'],
    );

    final positions = _extractList(
      _dashboard['positions'],
    );

    final orders = _extractList(
      _dashboard['orders'],
    );

    final trades = _extractList(
      _dashboard['trades'],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Broker Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadDashboard,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _AccountCard(
              broker: broker,
              name: name,
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _MoneyCard(
                    title: 'Available Margin',
                    value: availableMargin,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MoneyCard(
                    title: 'Used Margin',
                    value: usedMargin,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            const Text(
              'Portfolio',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _DataCard(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Holdings',
              count: holdings.length,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HoldingsScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _DataCard(
              icon: Icons.trending_up_rounded,
              title: 'Positions',
              count: positions.length,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PositionsScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _DataCard(
              icon: Icons.receipt_long_rounded,
              title: 'Orders',
              count: orders.length,
              color: Colors.deepPurple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrdersScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _DataCard(
              icon: Icons.swap_horiz_rounded,
              title: 'Trades',
              count: trades.length,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TradesScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Broker connection is active.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

class _AccountCard extends StatelessWidget {
  final String broker;
  final String name;

  const _AccountCard({
    required this.broker,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: Colors.blue,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  broker,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

class _MoneyCard extends StatelessWidget {
  final String title;
  final double value;
  final Color color;

  const _MoneyCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹ ${value.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DataCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color color;
  final VoidCallback? onTap;

  const _DataCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade500,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}