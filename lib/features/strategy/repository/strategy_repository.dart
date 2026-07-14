import '../models/strategy_model.dart';

class StrategyRepository {
  StrategyRepository._();

  static final StrategyRepository instance =
      StrategyRepository._();

  final List<StrategyModel> _strategies = [];

  StrategyModel? _selectedStrategy;

  List<StrategyModel> get strategies =>
      List.unmodifiable(_strategies);

  StrategyModel? get selectedStrategy =>
      _selectedStrategy;

  void saveStrategy(StrategyModel strategy) {
    final index = _strategies.indexWhere(
      (s) => s.id == strategy.id,
    );

    if (index == -1) {
      _strategies.add(strategy);
    } else {
      _strategies[index] = strategy;
    }
  }

  void deleteStrategy(String id) {
    _strategies.removeWhere(
      (s) => s.id == id,
    );

    if (_selectedStrategy?.id == id) {
      _selectedStrategy = null;
    }
  }

  void selectStrategy(String id) {
    try {
      _selectedStrategy = _strategies.firstWhere(
        (s) => s.id == id,
      );
    } catch (_) {
      _selectedStrategy = null;
    }
  }

  void clear() {
    _strategies.clear();
    _selectedStrategy = null;
  }
}