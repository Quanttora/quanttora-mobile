import '../data/strategy_repository.dart';
import '../models/strategy_model.dart';

class StrategyService {
  final StrategyRepository repository;

  StrategyService(this.repository);

  Future<void> createStrategy(StrategyModel strategy) async {
    await repository.createStrategy(strategy);
  }

  Future<void> updateStrategy(StrategyModel strategy) async {
    await repository.updateStrategy(strategy);
  }

  Future<void> deleteStrategy(String strategyId) async {
    await repository.deleteStrategy(strategyId);
  }

  Future<List<StrategyModel>> getAllStrategies() async {
    return repository.getAllStrategies();
  }

  Future<List<StrategyModel>> getActiveStrategies() async {
    return repository.getActiveStrategies();
  }

  Future<StrategyModel?> getStrategyById(String strategyId) async {
    return repository.getStrategyById(strategyId);
  }

  Future<void> setStrategyStatus({
    required String strategyId,
    required bool isActive,
  }) async {
    await repository.setStrategyStatus(
      strategyId: strategyId,
      isActive: isActive,
    );
  }
}
