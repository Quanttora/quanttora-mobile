import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final List<_WatchlistItem> _items = [
    const _WatchlistItem(
      symbol: 'RELIANCE',
      name: 'Reliance Industries',
    ),
    const _WatchlistItem(
      symbol: 'TCS',
      name: 'Tata Consultancy Services',
    ),
    const _WatchlistItem(
      symbol: 'HDFCBANK',
      name: 'HDFC Bank',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Watchlist',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showAddStockSheet,
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add stock',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshWatchlist,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 18),
            if (_items.isEmpty)
              _buildEmptyState()
            else
              ..._items.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _WatchlistTile(
                        item: entry.value,
                        onRemove: () => _removeItem(entry.key),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.visibility_rounded,
              color: AppColors.primary,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Stocks',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_items.length} ${_items.length == 1 ? 'stock' : 'stocks'} in your watchlist',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 48,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.visibility_off_rounded,
              color: AppColors.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Your watchlist is empty',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add stocks you want to track during the market.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: _showAddStockSheet,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Stock'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshWatchlist() async {
    await Future<void>.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) return;

    setState(() {});
  }

  void _removeItem(int index) {
    final removed = _items[index];

    setState(() {
      _items.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${removed.symbol} removed from watchlist',
        ),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            final insertIndex =
                index <= _items.length ? index : _items.length;

            setState(() {
              _items.insert(insertIndex, removed);
            });
          },
        ),
      ),
    );
  }

  void _showAddStockSheet() {
    final availableStocks = <_WatchlistItem>[
      const _WatchlistItem(
        symbol: 'INFY',
        name: 'Infosys',
      ),
      const _WatchlistItem(
        symbol: 'ICICIBANK',
        name: 'ICICI Bank',
      ),
      const _WatchlistItem(
        symbol: 'SBIN',
        name: 'State Bank of India',
      ),
      const _WatchlistItem(
        symbol: 'BHARTIARTL',
        name: 'Bharti Airtel',
      ),
      const _WatchlistItem(
        symbol: 'ITC',
        name: 'ITC',
      ),
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Add to Watchlist',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select a stock to track.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ...availableStocks.map(
                  (stock) {
                    final alreadyAdded = _items.any(
                      (item) => item.symbol == stock.symbol,
                    );

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(
                            alpha: 0.10,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.show_chart_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(
                        stock.symbol,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        stock.name,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: alreadyAdded
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.success,
                            )
                          : const Icon(
                              Icons.add_circle_outline_rounded,
                              color: AppColors.primary,
                            ),
                      onTap: alreadyAdded
                          ? null
                          : () {
                              setState(() {
                                _items.add(stock);
                              });

                              Navigator.pop(sheetContext);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${stock.symbol} added to watchlist',
                                  ),
                                ),
                              );
                            },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WatchlistItem {
  final String symbol;
  final String name;

  const _WatchlistItem({
    required this.symbol,
    required this.name,
  });
}

class _WatchlistTile extends StatelessWidget {
  const _WatchlistTile({
    required this.item,
    required this.onRemove,
  });

  final _WatchlistItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.symbol),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onRemove();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.candlestick_chart_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.symbol,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '--',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Waiting for data',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
