import 'package:flutter/material.dart';

class TradesCard extends StatelessWidget {
  final List<dynamic> trades;

  const TradesCard({
    super.key,
    required this.trades,
  });

  @override
  Widget build(BuildContext context) {
    double totalValue = 0;

    for (final trade in trades) {
      final qty = ((trade["quantity"] ?? 0) as num).toDouble();
      final price = ((trade["price"] ?? 0) as num).toDouble();
      totalValue += qty * price;
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
                Icons.swap_horiz_rounded,
                color: Colors.teal,
                size: 30,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Today's Trades",
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
                  color: Colors.teal.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${trades.length} Trades",
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.currency_rupee,
                  color: Colors.teal,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total Traded Value",
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₹${totalValue.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          if (trades.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: .05),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.swap_horizontal_circle_outlined,
                    size: 70,
                    color: Colors.teal,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No Trades Today",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Executed trades will automatically appear here.",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: trades.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 14),
              itemBuilder: (_, index) {
                final trade = trades[index];

                final symbol =
                    trade["trading_symbol"] ??
                    trade["tradingsymbol"] ??
                    "";

                final side =
                    trade["transaction_type"] ??
                    trade["side"] ??
                    "";

                final qty =
                    ((trade["quantity"] ?? 0) as num)
                        .toDouble();

                final price =
                    ((trade["price"] ?? 0) as num)
                        .toDouble();

                return _TradeTile(
                  symbol: symbol,
                  side: side,
                  quantity: qty,
                  price: price,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _TradeTile extends StatelessWidget {
  final String symbol;
  final String side;
  final double quantity;
  final double price;

  const _TradeTile({
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final buy = side.toUpperCase() == "BUY";

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor:
                (buy ? Colors.green : Colors.red)
                    .withValues(alpha: .10),
            child: Text(
              symbol.isEmpty ? "?" : symbol[0],
              style: TextStyle(
                color:
                    buy ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
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
                  "$side • Qty ${quantity.toStringAsFixed(0)}",
                ),
              ],
            ),
          ),

          Text(
            "₹${price.toStringAsFixed(2)}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}