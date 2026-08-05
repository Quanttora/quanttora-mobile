abstract class Indicator {
  /// Unique name
  String get name;

  /// Category
  String get category;

  /// Maximum score this indicator can contribute
  int get maxScore;

  /// Calculate score
  int calculate();

  /// Indicator passed?
  bool get passed;

  /// Why passed / failed
  List<String> get reasons;
}
