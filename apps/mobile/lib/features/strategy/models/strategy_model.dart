class StrategyModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String timeframe;
  final List<String> instruments;
  final int minimumAiScore;
  final double riskRewardRatio;
  final int maxTradesPerDay;
  final bool avoidNews;
  final bool avoidSideways;
  final bool avoidLowVolume;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StrategyModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.timeframe,
    required this.instruments,
    required this.minimumAiScore,
    required this.riskRewardRatio,
    required this.maxTradesPerDay,
    required this.avoidNews,
    required this.avoidSideways,
    required this.avoidLowVolume,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  StrategyModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? timeframe,
    List<String>? instruments,
    int? minimumAiScore,
    double? riskRewardRatio,
    int? maxTradesPerDay,
    bool? avoidNews,
    bool? avoidSideways,
    bool? avoidLowVolume,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StrategyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      timeframe: timeframe ?? this.timeframe,
      instruments: instruments ?? this.instruments,
      minimumAiScore: minimumAiScore ?? this.minimumAiScore,
      riskRewardRatio: riskRewardRatio ?? this.riskRewardRatio,
      maxTradesPerDay: maxTradesPerDay ?? this.maxTradesPerDay,
      avoidNews: avoidNews ?? this.avoidNews,
      avoidSideways: avoidSideways ?? this.avoidSideways,
      avoidLowVolume: avoidLowVolume ?? this.avoidLowVolume,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'timeframe': timeframe,
      'instruments': instruments,
      'minimumAiScore': minimumAiScore,
      'riskRewardRatio': riskRewardRatio,
      'maxTradesPerDay': maxTradesPerDay,
      'avoidNews': avoidNews,
      'avoidSideways': avoidSideways,
      'avoidLowVolume': avoidLowVolume,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory StrategyModel.fromMap(Map<String, dynamic> map) {
    return StrategyModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      timeframe: map['timeframe'] ?? '',
      instruments: List<String>.from(map['instruments'] ?? []),
      minimumAiScore: map['minimumAiScore'] ?? 0,
      riskRewardRatio: (map['riskRewardRatio'] ?? 0).toDouble(),
      maxTradesPerDay: map['maxTradesPerDay'] ?? 0,
      avoidNews: map['avoidNews'] ?? false,
      avoidSideways: map['avoidSideways'] ?? false,
      avoidLowVolume: map['avoidLowVolume'] ?? false,
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}