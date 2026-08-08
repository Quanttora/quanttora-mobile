enum OrderType { market, limit, stopLoss }

enum OrderSide { buy, sell }

class BrokerOrder {
  final String symbol;

  final OrderType orderType;

  final OrderSide side;

  final int quantity;

  final double price;

  const BrokerOrder({
    required this.symbol,
    required this.orderType,
    required this.side,
    required this.quantity,
    required this.price,
  });
}
