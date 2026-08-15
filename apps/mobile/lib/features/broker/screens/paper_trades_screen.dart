import 'package:flutter/material.dart';

import 'package:mobile/core/network/api_client.dart';

class PaperTradesScreen extends StatefulWidget {
  const PaperTradesScreen({super.key});

  @override
  State<PaperTradesScreen> createState() => _PaperTradesScreenState();
}

class _PaperTradesScreenState extends State<PaperTradesScreen> {
  final ApiClient _api = ApiClient.instance;

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _trades = [];

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
      final response = await _api.get('/broker/paper-trades');
      final rawTrades = response['trades'];

      final trades = rawTrades is List
          ? rawTrades
                .whereType<Map>()
                .map((trade) => Map<String, dynamic>.from(trade))
                .toList()
          : <Map<String, dynamic>>[];

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

  Future<void> _closeTrade(String id) async {
    try {
      await _api.post('/broker/paper-trades/$id/close', {});

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paper trade closed successfully.')),
      );

      await _loadTrades();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to close paper trade: $error')),
      );
    }
  }

  double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _text(dynamic value, [String fallback = '-']) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  Color _pnlColor(double pnl) {
    if (pnl > 0) return Colors.green;
    if (pnl < 0) return Colors.red;
    return Colors.grey.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        title: const Text('Paper Trading'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadTrades,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 52,
                color: Colors.red,
              ),
              const SizedBox(height: 14),
              const Text(
                'Unable to load paper trades',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 18),
              FilledButton(onPressed: _loadTrades, child: const Text('Retry')),
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
          padding: const EdgeInsets.all(24),
          children: [const SizedBox(height: 90), _emptyState()],
        ),
      );
    }

    final openCount = _trades
        .where((trade) => _text(trade['status']) == 'OPEN')
        .length;

    final totalPnl = _trades.fold<double>(
      0,
      (sum, trade) => sum + _number(trade['pnl']),
    );

    return RefreshIndicator(
      onRefresh: _loadTrades,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
        children: [
          _summaryCard(openCount: openCount, totalPnl: totalPnl),
          const SizedBox(height: 18),
          const Text(
            'Paper Trades',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ..._trades.map(_tradeCard),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Color(0xFFEAF2FF),
            child: Icon(
              Icons.science_rounded,
              size: 38,
              color: Color(0xFF155EEF),
            ),
          ),
          SizedBox(height: 18),
          Text(
            'No Paper Trades Yet',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Approved paper trades will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({required int openCount, required double totalPnl}) {
    final pnlColor = _pnlColor(totalPnl);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF155EEF), Color(0xFF4F7FFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF155EEF).withValues(alpha: .22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryItem(
              title: 'Open',
              value: '$openCount',
              icon: Icons.lock_open_rounded,
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: Colors.white.withValues(alpha: .25),
          ),
          Expanded(
            child: _summaryItem(
              title: 'Total P&L',
              value: '₹ ${totalPnl.toStringAsFixed(2)}',
              icon: Icons.account_balance_wallet_rounded,
              valueColor: totalPnl == 0 ? Colors.white : pnlColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required String title,
    required String value,
    required IconData icon,
    Color valueColor = Colors.white,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: .9), size: 25),
        const SizedBox(height: 7),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .82),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _tradeCard(Map<String, dynamic> trade) {
    final id = _text(trade['id']);
    final status = _text(trade['status']);
    final side = _text(trade['transactionType']).toUpperCase();
    final entry = _number(trade['entryPrice']);
    final current = _number(trade['currentPrice']);
    final pnl = _number(trade['pnl']);
    final quantity = _text(trade['quantity']);
    final orderType = _text(trade['orderType']);

    final isBuy = side == 'BUY';
    final pnlColor = _pnlColor(pnl);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .045),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isBuy
                      ? Colors.green.withValues(alpha: .10)
                      : Colors.red.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isBuy
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: isBuy ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      side.isEmpty ? 'PAPER TRADE' : side,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      id,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: status == 'OPEN'
                      ? Colors.green.withValues(alpha: .10)
                      : Colors.grey.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'OPEN'
                        ? Colors.green.shade700
                        : Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _metric('Entry', '₹ ${entry.toStringAsFixed(2)}'),
              _metric('Current', '₹ ${current.toStringAsFixed(2)}'),
              _metric('Qty', quantity),
              _metric(
                'P&L',
                '₹ ${pnl.toStringAsFixed(2)}',
                valueColor: pnlColor,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                orderType,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const Spacer(),
              if (status == 'OPEN')
                OutlinedButton.icon(
                  onPressed: () => _confirmClose(id),
                  icon: const Icon(Icons.stop_circle_outlined, size: 18),
                  label: const Text('Close Trade'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String title, String value, {Color? valueColor}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.black87,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClose(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Close Paper Trade?'),
          content: const Text('This will mark the paper trade as CLOSED.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Close Trade'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _closeTrade(id);
    }
  }
}
