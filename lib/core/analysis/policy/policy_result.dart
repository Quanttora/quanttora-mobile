class PolicyResult {
  final bool allowed;
  final List<String> blockingReasons;
  final List<String> passedRules;

  const PolicyResult({
    required this.allowed,
    required this.blockingReasons,
    required this.passedRules,
  });

  bool get blocked => !allowed;
}
