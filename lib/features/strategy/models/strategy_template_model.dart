class StrategyTemplateModel {
  final String id;

  /// Example:
  /// EMA 22/33 Scalping
  final String name;

  /// Short description shown to the trader
  final String description;

  /// Category
  /// Scalping / Intraday / Swing / Positional
  final String category;

  /// Suggested timeframe
  final String timeframe;

  /// Beginner / Intermediate / Advanced
  final String difficulty;

  /// Risk Level
  /// Low / Medium / High
  final String riskLevel;

  /// Approximate win rate (historical template estimate)
  final double expectedWinRate;

  /// Default AI score required
  final int minimumAiScore;

  /// Can user edit after creating?
  final bool isEditable;

  /// Is this an official Quanttora strategy?
  final bool isOfficial;

  const StrategyTemplateModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.timeframe,
    required this.difficulty,
    required this.riskLevel,
    required this.expectedWinRate,
    required this.minimumAiScore,
    required this.isEditable,
    required this.isOfficial,
  });

  StrategyTemplateModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? timeframe,
    String? difficulty,
    String? riskLevel,
    double? expectedWinRate,
    int? minimumAiScore,
    bool? isEditable,
    bool? isOfficial,
  }) {
    return StrategyTemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      timeframe: timeframe ?? this.timeframe,
      difficulty: difficulty ?? this.difficulty,
      riskLevel: riskLevel ?? this.riskLevel,
      expectedWinRate: expectedWinRate ?? this.expectedWinRate,
      minimumAiScore: minimumAiScore ?? this.minimumAiScore,
      isEditable: isEditable ?? this.isEditable,
      isOfficial: isOfficial ?? this.isOfficial,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'timeframe': timeframe,
      'difficulty': difficulty,
      'riskLevel': riskLevel,
      'expectedWinRate': expectedWinRate,
      'minimumAiScore': minimumAiScore,
      'isEditable': isEditable,
      'isOfficial': isOfficial,
    };
  }

  factory StrategyTemplateModel.fromMap(Map<String, dynamic> map) {
    return StrategyTemplateModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      timeframe: map['timeframe'] ?? '',
      difficulty: map['difficulty'] ?? '',
      riskLevel: map['riskLevel'] ?? '',
      expectedWinRate: (map['expectedWinRate'] ?? 0).toDouble(),
      minimumAiScore: map['minimumAiScore'] ?? 90,
      isEditable: map['isEditable'] ?? true,
      isOfficial: map['isOfficial'] ?? false,
    );
  }
}
