class PaperTrade {
  final String id;
  final String instrumentToken;
  final int quantity;
  final String product;
  final String validity;
  final double entryPrice;
  final double currentPrice;
  final String orderType;
  final String transactionType;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaperTrade({
    required this.id,
    required this.instrumentToken,
    required this.quantity,
    required this.product,
    required this.validity,
    required this.entryPrice,
    required this.currentPrice,
    required this.orderType,
    required this.transactionType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  double get pnl {
    final difference = currentPrice - entryPrice;
    final signedDifference = transactionType.toUpperCase() == 'SELL'
        ? -difference
        : difference;

    return signedDifference * quantity;
  }

  PaperTrade copyWith({
    double? currentPrice,
    String? status,
    DateTime? updatedAt,
  }) {
    return PaperTrade(
      id: id,
      instrumentToken: instrumentToken,
      quantity: quantity,
      product: product,
      validity: validity,
      entryPrice: entryPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      orderType: orderType,
      transactionType: transactionType,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'instrumentToken': instrumentToken,
      'quantity': quantity,
      'product': product,
      'validity': validity,
      'entryPrice': entryPrice,
      'currentPrice': currentPrice,
      'pnl': pnl,
      'orderType': orderType,
      'transactionType': transactionType,
      'status': status,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }
}
