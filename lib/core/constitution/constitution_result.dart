import 'constitution_rule.dart';

class ConstitutionResult {
  final bool canAnalyze;
  final List<ConstitutionRule> rules;
  final String? blockReason;

  const ConstitutionResult({
    required this.canAnalyze,
    required this.rules,
    this.blockReason,
  });

  int get passedRules => rules.where((rule) => rule.isPassed).length;

  int get failedRules => rules.where((rule) => !rule.isPassed).length;
}
