import 'package:flutter/material.dart';

import '../broker_service.dart';

class HoldingsScreen extends StatefulWidget {
  const HoldingsScreen({super.key});

  @override
  State<HoldingsScreen> createState() => _HoldingsScreenState();
}

class _HoldingsScreenState extends State<HoldingsScreen> {
  final BrokerService _brokerService = BrokerService();

  bool _loading = true;
  String? _error;
  List _holdings = [];

  @override
  void initState() {
    super.initState();
    _loadHoldings();
  }

  Future<void> _loadHoldings() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dashboard = await _brokerService.getDashboard();

      final holdingsData = dashboard['holdings'];

      List holdings = [];

      if (holdingsData is Map &&
          holdingsData['data'] is List) {
        holdings = holdingsData['data'];
      } else if (holdingsData is List) {
        holdings = holdingsData;
      }

      if (!mounted) return;

      setState(() {
        _holdings = holdings;
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

  String _text(dynamic value) {
    return value?.toString() ?? '-';
  }

  double _number(dynamic value) {
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
        title: const Text('Holdings'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadHoldings,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
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
              const SizedBox(height: 14),
              const Text(
                'Unable to load holdings',
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
                onPressed: _loadHoldings,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_holdings.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadHoldings,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 60,
              color: Colors.grey,
            ),
            SizedBox(height: 18),
            Center(
              child: Text(
                'No Holdings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                'Your long-term holdings will appear here.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHoldings,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _holdings.length,
        itemBuilder: (context, index) {
          final holding = _holdings[index];

          if (holding is! Map) {
            return const SizedBox.shrink();
          }

          return _HoldingCard(
            holding: holding,
            text: _text,
            number: _number,
          );
        },
      ),
    );
  }
}

class _HoldingCard extends StatelessWidget {
  final Map holding;
  final String Function(dynamic) text;
  final double Function(dynamic) number;

  const _HoldingCard({
    required this.holding,
    required this.text,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = text(
      holding['trading_symbol'] ??
          holding['symbol'] ??
          holding['tradingsymbol'],
    );

    final quantity = number(
      holding['quantity'] ??
          holding['qty'],
    );

    final averagePrice = number(
      holding['average_price'] ??
          holding['avg_price'],
    );

    final lastPrice = number(
      holding['last_price'] ??
          holding['ltp'],
    );

    final pnl = number(
      holding['pnl'] ??
          holding['unrealised_pnl'],
    );

    final pnlColor = pnl >= 0
        ? Colors.green
        : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  symbol,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '₹ ${pnl.toStringAsFixed(2)}',
                style: TextStyle(
                  color: pnlColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const Divider(height: 28),

          Row(
            children: [
              Expanded(
                child: _Value(
                  title: 'Quantity',
                  value: quantity.toStringAsFixed(0),
                ),
              ),
              Expanded(
                child: _Value(
                  title: 'Avg. Price',
                  value: '₹ ${averagePrice.toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _Value(
                  title: 'LTP',
                  value: '₹ ${lastPrice.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Value extends StatelessWidget {
  final String title;
  final String value;

  const _Value({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}