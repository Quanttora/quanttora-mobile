import 'package:flutter/material.dart';

import '../broker_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final BrokerService _brokerService = BrokerService();

  bool _loading = true;
  String? _error;
  List _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dashboard = await _brokerService.getDashboard();

      final ordersData = dashboard['orders'];

      List orders = [];

      if (ordersData is Map && ordersData['data'] is List) {
        orders = ordersData['data'];
      } else if (ordersData is List) {
        orders = ordersData;
      }

      if (!mounted) return;

      setState(() {
        _orders = orders;
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
        title: const Text('Orders'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadOrders,
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
                'Unable to load orders',
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
                onPressed: _loadOrders,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadOrders,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Icon(
              Icons.receipt_long_rounded,
              size: 60,
              color: Colors.grey,
            ),
            SizedBox(height: 18),
            Center(
              child: Text(
                'No Orders',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                'Your orders will appear here.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];

          if (order is! Map) {
            return const SizedBox.shrink();
          }

          return _OrderCard(
            order: order,
            text: _text,
            number: _number,
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map order;
  final String Function(dynamic) text;
  final double Function(dynamic) number;

  const _OrderCard({
    required this.order,
    required this.text,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = text(
      order['trading_symbol'] ??
          order['symbol'] ??
          order['tradingsymbol'],
    );

    final status = text(
      order['status'],
    ).toUpperCase();

    final transactionType = text(
      order['transaction_type'] ??
          order['side'],
    ).toUpperCase();

    final quantity = number(
      order['quantity'] ??
          order['qty'],
    );

    final price = number(
      order['price'] ??
          order['average_price'] ??
          order['avg_price'],
    );

    final orderType = text(
      order['order_type'],
    );

    final statusColor = _statusColor(status);

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
                  color: Colors.deepPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.deepPurple,
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
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
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
                  title: 'Side',
                  value: transactionType,
                  valueColor: sideColor,
                ),
              ),
              Expanded(
                child: _Value(
                  title: 'Quantity',
                  value: quantity.toStringAsFixed(0),
                ),
              ),
              Expanded(
                child: _Value(
                  title: 'Price',
                  value: '₹ ${price.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _Value(
                  title: 'Order Type',
                  value: orderType,
                ),
              ),
              Expanded(
                child: _Value(
                  title: 'Order ID',
                  value: text(
                    order['order_id'] ??
                        order['order_id_str'],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'COMPLETE':
      case 'COMPLETED':
        return Colors.green;

      case 'REJECTED':
      case 'CANCELLED':
        return Colors.red;

      case 'OPEN':
      case 'PENDING':
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }
}

class _Value extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _Value({
    required this.title,
    required this.value,
    this.valueColor,
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
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}