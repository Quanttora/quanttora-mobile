class FundsModel {
  final double availableMargin;
  final double usedMargin;

  const FundsModel({
    required this.availableMargin,
    required this.usedMargin,
  });

  factory FundsModel.fromJson(Map<String, dynamic> json) {
    final equity = json['data']['equity'];

    return FundsModel(
      availableMargin:
          (equity['available_margin'] ?? 0).toDouble(),
      usedMargin:
          (equity['used_margin'] ?? 0).toDouble(),
    );
  }
}