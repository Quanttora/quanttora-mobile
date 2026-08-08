class TradeHistoryModel {
  final String id;
  final String userId;
  final String? strategyId;
  final String instrument;
  final String? symbol;
  final String direction;
  final String? tradingMode;
  final int? aiScore;
  final double? entryPrice;
  final double? stopLoss;
  final double? targetPrice;
  final double? riskRewardRatio;
  final String status;
  final bool isPaperTrade;
  final String? broker;
  final String? brokerOrderId;
  final DateTime executedAt;
  final DateTime? closedAt;
  final DateTime createdAt;

  const TradeHistoryModel({
    required this.id,
    required this.userId,
    required this.strategyId,
    required this.instrument,
    required this.symbol,
    required this.direction,
    required this.tradingMode,
    required this.aiScore,
    required this.entryPrice,
    required this.stopLoss,
    required this.targetPrice,
    required this.riskRewardRatio,
    required this.status,
    required this.isPaperTrade,
    required this.broker,
    required this.brokerOrderId,
    required this.executedAt,
    required this.closedAt,
    required this.createdAt,
  });

  factory TradeHistoryModel.fromMap(Map<String, dynamic> map) {
    return TradeHistoryModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      strategyId: map['strategy_id']?.toString(),
      instrument: map['instrument']?.toString() ?? '',
      symbol: map['symbol']?.toString(),
      direction: map['direction']?.toString() ?? '',
      tradingMode: map['trading_mode']?.toString(),
      aiScore: (map['ai_score'] as num?)?.toInt(),
      entryPrice: (map['entry_price'] as num?)?.toDouble(),
      stopLoss: (map['stop_loss'] as num?)?.toDouble(),
      targetPrice: (map['target_price'] as num?)?.toDouble(),
      riskRewardRatio: (map['risk_reward_ratio'] as num?)?.toDouble(),
      status: map['status']?.toString() ?? 'executed',
      isPaperTrade: map['is_paper_trade'] as bool? ?? true,
      broker: map['broker']?.toString(),
      brokerOrderId: map['broker_order_id']?.toString(),
      executedAt: DateTime.parse(map['executed_at'].toString()),
      closedAt: map['closed_at'] == null
          ? null
          : DateTime.parse(map['closed_at'].toString()),
      createdAt: DateTime.parse(map['created_at'].toString()),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'strategy_id': strategyId,
      'instrument': instrument,
      'symbol': symbol,
      'direction': direction,
      'trading_mode': tradingMode,
      'ai_score': aiScore,
      'entry_price': entryPrice,
      'stop_loss': stopLoss,
      'target_price': targetPrice,
      'risk_reward_ratio': riskRewardRatio,
      'status': status,
      'is_paper_trade': isPaperTrade,
      'broker': broker,
      'broker_order_id': brokerOrderId,
      'executed_at': executedAt.toUtc().toIso8601String(),
      'closed_at': closedAt?.toUtc().toIso8601String(),
    };
  }
}
