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
      (item) => item.id == strategy.id,
    );

    if (index == -1) {
      _strategies.add(strategy);
    } else {
      _strategies[index] = strategy;
    }
  }

  void selectStrategy(String id) {
    for (final strategy in _strategies) {
      if (strategy.id == id) {
        _selectedStrategy = strategy;
        return;
      }
    }
  }

  void deleteStrategy(String id) {
    _strategies.removeWhere(
      (item) => item.id == id,
    );

    if (_selectedStrategy?.id == id) {
      _selectedStrategy = null;
    }
  }

  void clear() {
    _strategies.clear();
    _selectedStrategy = null;
  }
}