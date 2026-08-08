import 'package:flutter/material.dart';

class OrdersCard extends StatelessWidget {
  final List<dynamic> orders;

  const OrdersCard({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
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
                Icons.receipt_long_rounded,
                color: Colors.orange,
                size: 30,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Today's Orders",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${orders.length} Orders",
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (orders.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: .05),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 70,
                    color: Colors.orange,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No Orders Today",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Today's completed and pending orders will appear here.",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, index) {
                final order = orders[index];

                final symbol =
                    order["trading_symbol"] ?? order["tradingsymbol"] ?? "";

                final side = order["transaction_type"] ?? order["side"] ?? "";

                final status = order["status"] ?? "";

                final qty = ((order["quantity"] ?? 0) as num).toDouble();

                final price = ((order["price"] ?? 0) as num).toDouble();

                return _OrderTile(
                  symbol: symbol,
                  side: side,
                  status: status,
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

class _OrderTile extends StatelessWidget {
  final String symbol;
  final String side;
  final String status;
  final double quantity;
  final double price;

  const _OrderTile({
    required this.symbol,
    required this.side,
    required this.status,
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
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: (buy ? Colors.green : Colors.red).withValues(
              alpha: .10,
            ),
            child: Text(
              symbol.isEmpty ? "?" : symbol[0],
              style: TextStyle(
                color: buy ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 4),
                Text("$side • Qty ${quantity.toStringAsFixed(0)}"),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹${price.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
