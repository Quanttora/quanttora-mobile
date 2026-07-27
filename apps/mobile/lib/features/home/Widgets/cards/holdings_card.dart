import 'package:flutter/material.dart';

class HoldingsCard extends StatelessWidget {
  final List<dynamic> holdings;

  const HoldingsCard({
    super.key,
    required this.holdings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    double totalValue = 0;
    double totalPnL = 0;

    for (final item in holdings) {
      final qty = (item['quantity'] ?? 0).toDouble();
      final ltp = (item['last_price'] ?? 0).toDouble();
      final pnl = (item['pnl'] ?? 0).toDouble();

      totalValue += qty * ltp;
      totalPnL += pnl;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.blue,
                ),
                const SizedBox(width: 10),
                Text(
                  "My Holdings",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(.08),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    "${holdings.length} Stocks",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            Row(
              children: [

                Expanded(
                  child: _SummaryTile(
                    title: "Portfolio Value",
                    value:
                        "₹${totalValue.toStringAsFixed(2)}",
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _SummaryTile(
                    title: "Overall P&L",
                    value:
                        "₹${totalPnL.toStringAsFixed(2)}",
                    valueColor: totalPnL >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            if (holdings.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: const [

                    Icon(
                      Icons.pie_chart_outline,
                      size: 70,
                      color: Colors.grey,
                    ),

                    SizedBox(height: 18),

                    Text(
                      "No Holdings Found",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      "Once you buy stocks from Upstox, they will automatically appear here.",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: holdings.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 14),
                itemBuilder: (_, index) {
                  final stock = holdings[index];

                  final company =
                      stock["company_name"] ?? "";

                  final symbol =
                      stock["trading_symbol"] ??
                          stock["tradingsymbol"] ??
                          "";

                  final qty =
                      (stock["quantity"] ?? 0).toDouble();

                  final ltp =
                      (stock["last_price"] ?? 0).toDouble();

                  final pnl =
                      (stock["pnl"] ?? 0).toDouble();

                  final value = qty * ltp;

                  return _HoldingTile(
                    company: company,
                    symbol: symbol,
                    quantity: qty,
                    value: value,
                    ltp: ltp,
                    pnl: pnl,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _SummaryTile({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _HoldingTile extends StatelessWidget {
  final String company;
  final String symbol;
  final double quantity;
  final double value;
  final double ltp;
  final double pnl;

  const _HoldingTile({
    required this.company,
    required this.symbol,
    required this.quantity,
    required this.value,
    required this.ltp,
    required this.pnl,
  });

  @override
  Widget build(BuildContext context) {
    final isProfit = pnl >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
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
                backgroundColor: Colors.blue.shade50,
                child: Text(
                  symbol.isNotEmpty
                      ? symbol.substring(0, 1)
                      : "?",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
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
                      company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      symbol,
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
                    "₹${value.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    isProfit
                        ? "+₹${pnl.toStringAsFixed(2)}"
                        : "-₹${pnl.abs().toStringAsFixed(2)}",
                    style: TextStyle(
                      color: isProfit
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
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
                  title: "Quantity",
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
                  title: "Value",
                  value: "₹${value.toStringAsFixed(2)}",
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