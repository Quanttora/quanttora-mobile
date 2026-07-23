import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/strategy_repository.dart';
import '../data/supabase_strategy_repository.dart';
import '../services/strategy_service.dart';

final strategyRepositoryProvider = Provider<StrategyRepository>((ref) {
  return SupabaseStrategyRepository();
});

final strategyServiceProvider = Provider<StrategyService>((ref) {
  return StrategyService(
    ref.read(strategyRepositoryProvider),
  );
});