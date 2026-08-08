enum RuleGroupOperator { and, or }

class StrategyRuleGroupModel {
  final String id;
  final String strategyId;

  /// Group Name
  /// Example:
  /// Trend Confirmation
  /// Entry Confirmation
  /// Exit Rules
  final String name;

  /// AND / OR
  final RuleGroupOperator groupOperator;

  /// Execution Order
  final int priority;

  /// Enabled / Disabled
  final bool isEnabled;

  final DateTime createdAt;

  const StrategyRuleGroupModel({
    required this.id,
    required this.strategyId,
    required this.name,
    required this.groupOperator,
    required this.priority,
    required this.isEnabled,
    required this.createdAt,
  });

  StrategyRuleGroupModel copyWith({
    String? id,
    String? strategyId,
    String? name,
    RuleGroupOperator? groupOperator,
    int? priority,
    bool? isEnabled,
    DateTime? createdAt,
  }) {
    return StrategyRuleGroupModel(
      id: id ?? this.id,
      strategyId: strategyId ?? this.strategyId,
      name: name ?? this.name,
      groupOperator: groupOperator ?? this.groupOperator,
      priority: priority ?? this.priority,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'strategyId': strategyId,
      'name': name,
      'groupOperator': groupOperator.name,
      'priority': priority,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StrategyRuleGroupModel.fromMap(Map<String, dynamic> map) {
    return StrategyRuleGroupModel(
      id: map['id'] ?? '',
      strategyId: map['strategyId'] ?? '',
      name: map['name'] ?? '',
      groupOperator: RuleGroupOperator.values.firstWhere(
        (e) => e.name == map['groupOperator'],
        orElse: () => RuleGroupOperator.and,
      ),
      priority: map['priority'] ?? 1,
      isEnabled: map['isEnabled'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
