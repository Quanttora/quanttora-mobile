import 'package:flutter/material.dart';

class PositionsCard extends StatelessWidget {
  final List<dynamic> positions;

  const PositionsCard({
    super.key,
    required this.positions,
  });

  @override
  Widget build(BuildContext context) {
    double totalPnl = 0;
    double totalMtm = 0;

    for (final item in positions) {
      totalPnl += ((item['pnl'] ?? 0) as num).toDouble();
      totalMtm += ((item['day_pnl'] ?? 0) as num).toDouble();
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.show_chart_rounded,
                color: Colors.deepPurple,
                size: 30,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Open Positions",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${positions.length} Active",
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  title: "Open P&L",
                  value: "₹${totalPnl.toStringAsFixed(2)}",
                  color: totalPnl >= 0
                      ? Colors.green
                      : Colors.red,
                  icon: Icons.currency_rupee,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SummaryTile(
                  title: "Today's MTM",
                  value: "₹${totalMtm.toStringAsFixed(2)}",
                  color: totalMtm >= 0
                      ? Colors.green
                      : Colors.red,
                  icon: Icons.trending_up,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          if (positions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: .05),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.show_chart_outlined,
                    size: 70,
                    color: Colors.deepPurple,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No Open Positions",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Your live positions from Upstox will automatically appear here.",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: positions.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 14),
              itemBuilder: (_, index) {
                final item = positions[index];

                final symbol =
                    item['trading_symbol'] ??
                    item['tradingsymbol'] ??
                    '';

                final product =
                    item['product'] ?? '';

                final qty =
                    ((item['quantity'] ?? 0) as num)
                        .toDouble();

                final ltp =
                    ((item['last_price'] ?? 0) as num)
                        .toDouble();

                final pnl =
                    ((item['pnl'] ?? 0) as num)
                        .toDouble();

                final mtm =
                    ((item['day_pnl'] ?? 0) as num)
                        .toDouble();

                return _PositionTile(
                  symbol: symbol,
                  product: product,
                  quantity: qty,
                  ltp: ltp,
                  pnl: pnl,
                  mtm: mtm,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryTile({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
class _PositionTile extends StatelessWidget {
  final String symbol;
  final String product;
  final double quantity;
  final double ltp;
  final double pnl;
  final double mtm;

  const _PositionTile({
    required this.symbol,
    required this.product,
    required this.quantity,
    required this.ltp,
    required this.pnl,
    required this.mtm,
  });

  @override
  Widget build(BuildContext context) {
    final pnlColor = pnl >= 0 ? Colors.green : Colors.red;
    final mtmColor = mtm >= 0 ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    Colors.deepPurple.withValues(alpha: .10),
                child: Text(
                  symbol.isEmpty
                      ? "?"
                      : symbol.substring(0, 1),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      symbol,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      product,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹${pnl.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: pnlColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "MTM ₹${mtm.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: mtmColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Divider(),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  title: "Qty",
                  value: quantity.toStringAsFixed(0),
                ),
              ),
              Expanded(
                child: _InfoTile(
                  title: "LTP",
                  value: "₹${ltp.toStringAsFixed(2)}",
                ),
              ),
              Expanded(
                child: _InfoTile(
                  title: "Product",
                  value: product,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}