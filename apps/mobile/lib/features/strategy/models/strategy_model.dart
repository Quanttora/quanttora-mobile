class StrategyModel {
  final String id;

  final String name;

  final String market;

  final String tradingMode;

  final List<String> indicators;

  final double riskPerTrade;

  final String minimumRiskReward;

  final double maximumDailyLoss;

  final int maximumTrades;

  final DateTime createdAt;

  const StrategyModel({
    required this.id,
    required this.name,
    required this.market,
    required this.tradingMode,
    required this.indicators,
    required this.riskPerTrade,
    required this.minimumRiskReward,
    required this.maximumDailyLoss,
    required this.maximumTrades,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'market': market,
      'tradingMode': tradingMode,
      'indicators': indicators,
      'riskPerTrade': riskPerTrade,
      'minimumRiskReward': minimumRiskReward,
      'maximumDailyLoss': maximumDailyLoss,
      'maximumTrades': maximumTrades,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StrategyModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return StrategyModel(
      id: map['id'],
      name: map['name'],
      market: map['market'],
      tradingMode: map['tradingMode'],
      indicators: List<String>.from(
        map['indicators'] ?? [],
      ),
      riskPerTrade:
          (map['riskPerTrade'] ?? 1).toDouble(),
      minimumRiskReward:
          map['minimumRiskReward'] ?? '1:3',
      maximumDailyLoss:
          (map['maximumDailyLoss'] ?? 0).toDouble(),
      maximumTrades:
          map['maximumTrades'] ?? 3,
      createdAt: DateTime.parse(
        map['createdAt'],
      ),
    );
  }

  StrategyModel copyWith({
    String? id,
    String? name,
    String? market,
    String? tradingMode,
    List<String>? indicators,
    double? riskPerTrade,
    String? minimumRiskReward,
    double? maximumDailyLoss,
    int? maximumTrades,
    DateTime? createdAt,
  }) {
    return StrategyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      market: market ?? this.market,
      tradingMode:
          tradingMode ?? this.tradingMode,
      indicators:
          indicators ?? this.indicators,
      riskPerTrade:
          riskPerTrade ?? this.riskPerTrade,
      minimumRiskReward:
          minimumRiskReward ??
              this.minimumRiskReward,
      maximumDailyLoss:
          maximumDailyLoss ??
              this.maximumDailyLoss,
      maximumTrades:
          maximumTrades ??
              this.maximumTrades,
      createdAt:
          createdAt ?? this.createdAt,
    );
  }
}