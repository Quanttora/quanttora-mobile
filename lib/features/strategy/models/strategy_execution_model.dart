enum StrategyExecutionStatus {
  pending,
  analyzing,
  completed,
  failed,
}

class StrategyExecutionModel {
  final String id;
  final String strategyId;

  /// Example:
  /// NIFTY
  /// BANKNIFTY
  /// RELIANCE
  final String instrument;

  /// Example:
  /// NIFTY 25000 CE
  final String symbol;

  /// Current Market Price
  final double currentPrice;

  /// AI Score (0-100)
  final double aiScore;

  /// Probability (0-100)
  final double probability;

  /// Suggested Entry
  final double entryPrice;

  /// Suggested Stop Loss
  final double stopLoss;

  /// Suggested Target
  final double targetPrice;

  /// Risk Reward Ratio
  final double riskRewardRatio;

  /// Overall Status
  final StrategyExecutionStatus status;

  /// AI Explanation
  final List<String> reasons;

  final DateTime executedAt;

  const StrategyExecutionModel({
    required this.id,
    required this.strategyId,
    required this.instrument,
    required this.symbol,
    required this.currentPrice,
    required this.aiScore,
    required this.probability,
    required this.entryPrice,
    required this.stopLoss,
    required this.targetPrice,
    required this.riskRewardRatio,
    required this.status,
    required this.reasons,
    required this.executedAt,
  });

  StrategyExecutionModel copyWith({
    String? id,
    String? strategyId,
    String? instrument,
    String? symbol,
    double? currentPrice,
    double? aiScore,
    double? probability,
    double? entryPrice,
    double? stopLoss,
    double? targetPrice,
    double? riskRewardRatio,
    StrategyExecutionStatus? status,
    List<String>? reasons,
    DateTime? executedAt,
  }) {
    return StrategyExecutionModel(
      id: id ?? this.id,
      strategyId: strategyId ?? this.strategyId,
      instrument: instrument ?? this.instrument,
      symbol: symbol ?? this.symbol,
      currentPrice: currentPrice ?? this.currentPrice,
      aiScore: aiScore ?? this.aiScore,
      probability: probability ?? this.probability,
      entryPrice: entryPrice ?? this.entryPrice,
      stopLoss: stopLoss ?? this.stopLoss,
      targetPrice: targetPrice ?? this.targetPrice,
      riskRewardRatio: riskRewardRatio ?? this.riskRewardRatio,
      status: status ?? this.status,
      reasons: reasons ?? this.reasons,
      executedAt: executedAt ?? this.executedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'strategyId': strategyId,
      'instrument': instrument,
      'symbol': symbol,
      'currentPrice': currentPrice,
      'aiScore': aiScore,
      'probability': probability,
      'entryPrice': entryPrice,
      'stopLoss': stopLoss,
      'targetPrice': targetPrice,
      'riskRewardRatio': riskRewardRatio,
      'status': status.name,
      'reasons': reasons,
      'executedAt': executedAt.toIso8601String(),
    };
  }

  factory StrategyExecutionModel.fromMap(Map<String, dynamic> map) {
    return StrategyExecutionModel(
      id: map['id'] ?? '',
      strategyId: map['strategyId'] ?? '',
      instrument: map['instrument'] ?? '',
      symbol: map['symbol'] ?? '',
      currentPrice: (map['currentPrice'] ?? 0).toDouble(),
      aiScore: (map['aiScore'] ?? 0).toDouble(),
      probability: (map['probability'] ?? 0).toDouble(),
      entryPrice: (map['entryPrice'] ?? 0).toDouble(),
      stopLoss: (map['stopLoss'] ?? 0).toDouble(),
      targetPrice: (map['targetPrice'] ?? 0).toDouble(),
      riskRewardRatio:
          (map['riskRewardRatio'] ?? 0).toDouble(),
      status: StrategyExecutionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => StrategyExecutionStatus.pending,
      ),
      reasons: List<String>.from(map['reasons'] ?? []),
      executedAt: DateTime.parse(map['executedAt']),
    );
  }
}