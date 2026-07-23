import '../models/strategy_model.dart';

abstract class StrategyRepository {
  /// Create Strategy
  Future<void> createStrategy(StrategyModel strategy);

  /// Update Strategy
  Future<void> updateStrategy(StrategyModel strategy);

  /// Delete Strategy
  Future<void> deleteStrategy(String strategyId);

  /// Get Strategy by ID
  Future<StrategyModel?> getStrategyById(String strategyId);

  /// Get All Strategies
  Future<List<StrategyModel>> getAllStrategies();

  /// Get Active Strategies
  Future<List<StrategyModel>> getActiveStrategies();

  /// Enable / Disable Strategy
  Future<void> setStrategyStatus({
    required String strategyId,
    required bool isActive,
  });
}