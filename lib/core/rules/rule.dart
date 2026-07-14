abstract class Rule {
  const Rule();

  String get name;

  int get maxScore;

  bool get passed;

  int calculate();

  List<String> get reasons;
}