import 'package:flutter/material.dart';

import '../broker_service.dart';

class PositionsScreen extends StatefulWidget {
  const PositionsScreen({super.key});

  @override
  State<PositionsScreen> createState() => _PositionsScreenState();
}

class _PositionsScreenState extends State<PositionsScreen> {
  final BrokerService _brokerService = BrokerService();

  bool _loading = true;
  String? _error;
  List _positions = [];

  @override
  void initState() {
    super.initState();
    _loadPositions();
  }

  Future<void> _loadPositions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dashboard = await _brokerService.getDashboard();

      final positionsData = dashboard['positions'];

      List positions = [];

      if (positionsData is Map &&
          positionsData['data'] is List) {
        positions = positionsData['data'];
      } else if (positionsData is List) {
        positions = positionsData;
      }

      if (!mounted) return;

      setState(() {
        _positions = positions;
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
        title: const Text('Positions'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadPositions,
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
                'Unable to load positions',
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
                onPressed: _loadPositions,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_positions.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadPositions,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Icon(
              Icons.trending_up_rounded,
              size: 60,
              color: Colors.grey,
            ),
            SizedBox(height: 18),
            Center(
              child: Text(
                'No Positions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                'Your open trading positions will appear here.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPositions,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _positions.length,
        itemBuilder: (context, index) {
          final position = _positions[index];

          if (position is! Map) {
            return const SizedBox.shrink();
          }

          return _PositionCard(
            position: position,
            text: _text,
            number: _number,
          );
        },
      ),
    );
  }
}

class _PositionCard extends StatelessWidget {
  final Map position;
  final String Function(dynamic) text;
  final double Function(dynamic) number;

  const _PositionCard({
    required this.position,
    required this.text,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = text(
      position['trading_symbol'] ??
          position['symbol'] ??
          position['tradingsymbol'],
    );

    final quantity = number(
      position['quantity'] ??
          position['qty'] ??
          position['net_quantity'],
    );

    final averagePrice = number(
      position['average_price'] ??
          position['avg_price'],
    );

    final lastPrice = number(
      position['last_price'] ??
          position['ltp'],
    );

    final pnl = number(
      position['pnl'] ??
          position['unrealised_pnl'],
    );

    final pnlColor = pnl >= 0
        ? Colors.green
        : Colors.red;

    final side = quantity > 0
        ? 'LONG'
        : quantity < 0
            ? 'SHORT'
            : 'FLAT';

    final sideColor = quantity > 0
        ? Colors.green
        : quantity < 0
            ? Colors.red
            : Colors.grey;

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
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.green,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: sideColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  side,
                  style: TextStyle(
                    color: sideColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
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

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: pnlColor.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'P&L',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '₹ ${pnl.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: pnlColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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