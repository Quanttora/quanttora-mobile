enum RuleType {
  indicatorComparison,
  indicatorValue,
  priceAction,
  volume,
  candlestick,
  marketStructure,
  optionChain,
  news,
  riskManagement,
  custom,
}

enum ComparisonOperator {
  greaterThan,
  lessThan,
  greaterOrEqual,
  lessOrEqual,
  equal,
  notEqual,
  crossesAbove,
  crossesBelow,
  between,
}

class StrategyRuleModel {
  final String id;
  final String strategyId;

  final RuleType ruleType;

  final String leftSource;
  final String leftValue;

  final ComparisonOperator comparisonOperator;

  final String rightSource;
  final String rightValue;

  final bool isEnabled;

  final int priority;

  final DateTime createdAt;

  const StrategyRuleModel({
    required this.id,
    required this.strategyId,
    required this.ruleType,
    required this.leftSource,
    required this.leftValue,
    required this.comparisonOperator,
    required this.rightSource,
    required this.rightValue,
    required this.isEnabled,
    required this.priority,
    required this.createdAt,
  });

  StrategyRuleModel copyWith({
    String? id,
    String? strategyId,
    RuleType? ruleType,
    String? leftSource,
    String? leftValue,
    ComparisonOperator? comparisonOperator,
    String? rightSource,
    String? rightValue,
    bool? isEnabled,
    int? priority,
    DateTime? createdAt,
  }) {
    return StrategyRuleModel(
      id: id ?? this.id,
      strategyId: strategyId ?? this.strategyId,
      ruleType: ruleType ?? this.ruleType,
      leftSource: leftSource ?? this.leftSource,
      leftValue: leftValue ?? this.leftValue,
      comparisonOperator: comparisonOperator ?? this.comparisonOperator,
      rightSource: rightSource ?? this.rightSource,
      rightValue: rightValue ?? this.rightValue,
      isEnabled: isEnabled ?? this.isEnabled,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'strategyId': strategyId,
      'ruleType': ruleType.name,
      'leftSource': leftSource,
      'leftValue': leftValue,
      'comparisonOperator': comparisonOperator.name,
      'rightSource': rightSource,
      'rightValue': rightValue,
      'isEnabled': isEnabled,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StrategyRuleModel.fromMap(Map<String, dynamic> map) {
    return StrategyRuleModel(
      id: map['id'] ?? '',
      strategyId: map['strategyId'] ?? '',
      ruleType: RuleType.values.firstWhere(
        (e) => e.name == map['ruleType'],
        orElse: () => RuleType.custom,
      ),
      leftSource: map['leftSource'] ?? '',
      leftValue: map['leftValue'] ?? '',
      comparisonOperator: ComparisonOperator.values.firstWhere(
        (e) => e.name == map['comparisonOperator'],
        orElse: () => ComparisonOperator.equal,
      ),
      rightSource: map['rightSource'] ?? '',
      rightValue: map['rightValue'] ?? '',
      isEnabled: map['isEnabled'] ?? true,
      priority: map['priority'] ?? 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
