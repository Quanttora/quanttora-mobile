import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/strategy_model.dart';
import 'strategy_repository.dart';

class SupabaseStrategyRepository implements StrategyRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _table = 'strategies';

  @override
  Future<void> createStrategy(StrategyModel strategy) async {
    await _supabase.from(_table).insert(strategy.toMap());
  }

  @override
  Future<void> updateStrategy(StrategyModel strategy) async {
    await _supabase
        .from(_table)
        .update(strategy.toMap())
        .eq('id', strategy.id);
  }

  @override
  Future<void> deleteStrategy(String strategyId) async {
    await _supabase
        .from(_table)
        .delete()
        .eq('id', strategyId);
  }

  @override
  Future<List<StrategyModel>> getAllStrategies() async {
    final response = await _supabase
        .from(_table)
        .select()
        .order('createdAt', ascending: false);

    return (response as List)
        .map((e) => StrategyModel.fromMap(e))
        .toList();
  }

  @override
  Future<List<StrategyModel>> getActiveStrategies() async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('isActive', true)
        .order('createdAt', ascending: false);

    return (response as List)
        .map((e) => StrategyModel.fromMap(e))
        .toList();
  }

  @override
  Future<StrategyModel?> getStrategyById(String strategyId) async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('id', strategyId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return StrategyModel.fromMap(response);
  }

  @override
  Future<void> setStrategyStatus({
    required String strategyId,
    required bool isActive,
  }) async {
    await _supabase
        .from(_table)
        .update({'isActive': isActive})
        .eq('id', strategyId);
  }
}