import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/strategy_model.dart';
import 'strategy_providers.dart';

final strategyListProvider =
    FutureProvider<List<StrategyModel>>((ref) async {
  final service = ref.read(strategyServiceProvider);
  return service.getAllStrategies();
});