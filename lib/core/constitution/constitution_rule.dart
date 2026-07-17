enum ConstitutionStatus {
  pass,
  fail,
}

class ConstitutionRule {
  final String id;
  final String title;
  final String description;
  final ConstitutionStatus status;

  const ConstitutionRule({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
  });

  bool get isPassed => status == ConstitutionStatus.pass;
}