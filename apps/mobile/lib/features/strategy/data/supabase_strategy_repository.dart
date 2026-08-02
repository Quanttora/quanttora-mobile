import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/strategy_model.dart';
import 'strategy_repository.dart';

class SupabaseStrategyRepository implements StrategyRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _table = 'strategies';

  String get _userId {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    return user.id;
  }

  @override
  Future<void> createStrategy(StrategyModel strategy) async {
    final data = strategy.toMap();

    // Supabase/PostgreSQL generates the UUID.
    data.remove('id');

    // Always attach the authenticated user.
    data['user_id'] = _userId;

    await _supabase.from(_table).insert(data);
  }

  @override
  Future<void> updateStrategy(StrategyModel strategy) async {
    final data = strategy.toMap();

    data['user_id'] = _userId;
    data['updatedAt'] = DateTime.now().toIso8601String();

    await _supabase
        .from(_table)
        .update(data)
        .eq('id', strategy.id)
        .eq('user_id', _userId);
  }

  @override
  Future<void> deleteStrategy(String strategyId) async {
    await _supabase
        .from(_table)
        .delete()
        .eq('id', strategyId)
        .eq('user_id', _userId);
  }

  @override
  Future<List<StrategyModel>> getAllStrategies() async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('user_id', _userId)
        .order('createdAt', ascending: false);

    return (response as List)
        .map(
          (e) => StrategyModel.fromMap(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  @override
  Future<List<StrategyModel>> getActiveStrategies() async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('user_id', _userId)
        .eq('isActive', true)
        .order('createdAt', ascending: false);

    return (response as List)
        .map(
          (e) => StrategyModel.fromMap(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  @override
  Future<StrategyModel?> getStrategyById(String strategyId) async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('id', strategyId)
        .eq('user_id', _userId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return StrategyModel.fromMap(
      Map<String, dynamic>.from(response),
    );
  }

  @override
  Future<void> setStrategyStatus({
    required String strategyId,
    required bool isActive,
  }) async {
    await _supabase
        .from(_table)
        .update({
          'isActive': isActive,
          'updatedAt': DateTime.now().toIso8601String(),
        })
        .eq('id', strategyId)
        .eq('user_id', _userId);
  }
}