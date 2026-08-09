import 'package:flutter/material.dart';

import '../broker_service.dart';

class TradesScreen extends StatefulWidget {
  const TradesScreen({super.key});

  @override
  State<TradesScreen> createState() => _TradesScreenState();
}

class _TradesScreenState extends State<TradesScreen> {
  final BrokerService _brokerService = BrokerService();

  bool _loading = true;
  String? _error;
  List _trades = [];

  @override
  void initState() {
    super.initState();
    _loadTrades();
  }

  Future<void> _loadTrades() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dashboard = await _brokerService.getDashboard();

      final tradesData = dashboard['trades'];

      List trades = [];

      if (tradesData is Map && tradesData['data'] is List) {
        trades = tradesData['data'];
      } else if (tradesData is List) {
        trades = tradesData;
      }

      if (!mounted) return;

      setState(() {
        _trades = trades;
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
        title: const Text('Trades'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadTrades,
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
                'Unable to load trades',
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
                onPressed: _loadTrades,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_trades.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadTrades,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Icon(
              Icons.swap_horiz_rounded,
              size: 60,
              color: Colors.grey,
            ),
            SizedBox(height: 18),
            Center(
              child: Text(
                'No Trades',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                'Your executed trades will appear here.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTrades,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _trades.length,
        itemBuilder: (context, index) {
          final trade = _trades[index];

          if (trade is! Map) {
            return const SizedBox.shrink();
          }

          return _TradeCard(
            trade: trade,
            text: _text,
            number: _number,
          );
        },
      ),
    );
  }
}

class _TradeCard extends StatelessWidget {
  final Map trade;
  final String Function(dynamic) text;
  final double Function(dynamic) number;

  const _TradeCard({
    required this.trade,
    required this.text,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = text(
      trade['trading_symbol'] ??
          trade['symbol'] ??
          trade['tradingsymbol'],
    );

    final transactionType = text(
      trade['transaction_type'] ??
          trade['side'],
    ).toUpperCase();

    final quantity = number(
      trade['quantity'] ??
          trade['qty'],
    );

    final price = number(
      trade['traded_price'] ??
          trade['average_price'] ??
          trade['price'] ??
          trade['avg_price'],
    );

    final tradeId = text(
      trade['trade_id'] ??
          trade['trade_id_str'],
    );

    final exchange = text(
      trade['exchange'],
    );

    final sideColor = transactionType == 'BUY'
        ? Colors.green
        : transactionType == 'SELL'
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
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  color: Colors.orange,
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
                  transactionType,
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
                  title: 'Traded Price',
                  value: '₹ ${price.toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _Value(
                  title: 'Exchange',
                  value: exchange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _Value(
            title: 'Trade ID',
            value: tradeId,
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}