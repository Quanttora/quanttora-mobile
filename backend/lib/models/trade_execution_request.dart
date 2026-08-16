class TradeExecutionRequest {
  final String instrumentToken;
  final int quantity;
  final String product;
  final String validity;
  final double price;
  final String orderType;
  final String transactionType;

  final bool constitutionPassed;
  final bool strategyPolicyPassed;

  final int aiConfidence;
  final int minimumAiScore;

  final int tradesToday;
  final int maxTradesPerDay;

  final double riskReward;
  final double minimumRiskReward;

  /// True only when this request is intended for paper trading.
  final bool paperTrade;

  /// Explicit trader confirmation is required before live execution.
  final bool explicitConfirmation;

  const TradeExecutionRequest({
    required this.instrumentToken,
    required this.quantity,
    required this.product,
    required this.validity,
    required this.price,
    required this.orderType,
    required this.transactionType,
    required this.constitutionPassed,
    required this.strategyPolicyPassed,
    required this.aiConfidence,
    required this.minimumAiScore,
    required this.tradesToday,
    required this.maxTradesPerDay,
    required this.riskReward,
    required this.minimumRiskReward,
    required this.paperTrade,
    required this.explicitConfirmation,
  });

  factory TradeExecutionRequest.fromMap(Map<String, dynamic> map) {
    return TradeExecutionRequest(
      instrumentToken: map['instrumentToken']?.toString().trim() ?? '',
      quantity: int.tryParse(map['quantity']?.toString() ?? '') ?? 0,
      product: map['product']?.toString().trim() ?? '',
      validity: map['validity']?.toString().trim() ?? '',
      price: double.tryParse(map['price']?.toString() ?? '') ?? 0,
      orderType: map['orderType']?.toString().trim() ?? '',
      transactionType: map['transactionType']?.toString().trim() ?? '',
      constitutionPassed: map['constitutionPassed'] == true,
      strategyPolicyPassed: map['strategyPolicyPassed'] == true,
      aiConfidence: int.tryParse(map['aiConfidence']?.toString() ?? '') ?? 0,
      minimumAiScore:
          int.tryParse(map['minimumAiScore']?.toString() ?? '') ?? 0,
      tradesToday: int.tryParse(map['tradesToday']?.toString() ?? '') ?? 0,
      maxTradesPerDay:
          int.tryParse(map['maxTradesPerDay']?.toString() ?? '') ?? 0,
      riskReward: double.tryParse(map['riskReward']?.toString() ?? '') ?? 0,
      minimumRiskReward:
          double.tryParse(map['minimumRiskReward']?.toString() ?? '') ?? 0,
      paperTrade: map['paperTrade'] == true,
      explicitConfirmation: map['explicitConfirmation'] == true,
    );
  }
}
