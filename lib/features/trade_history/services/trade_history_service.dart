import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/trade_history_model.dart';

class TradeHistoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _table = 'trade_history';

  User get _currentUser {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw StateError('User must be authenticated to access trade history.');
    }

    return user;
  }

  Future<List<TradeHistoryModel>> getTradeHistory() async {
    final user = _currentUser;

    final response = await _supabase
        .from(_table)
        .select()
        .eq('user_id', user.id)
        .order('executed_at', ascending: false);

    return (response as List<dynamic>)
        .map(
          (row) =>
              TradeHistoryModel.fromMap(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<int> getTodayTradeCount({String? strategyId}) async {
    final user = _currentUser;

    final now = DateTime.now();

    final startOfTodayLocal = DateTime(now.year, now.month, now.day);

    final startOfTomorrowLocal = startOfTodayLocal.add(const Duration(days: 1));

    var query = _supabase
        .from(_table)
        .select('id')
        .eq('user_id', user.id)
        .inFilter('status', const ['executed', 'closed'])
        .gte('executed_at', startOfTodayLocal.toUtc().toIso8601String())
        .lt('executed_at', startOfTomorrowLocal.toUtc().toIso8601String());

    if (strategyId != null && strategyId.trim().isNotEmpty) {
      query = query.eq('strategy_id', strategyId.trim());
    }

    final response = await query;

    return (response as List<dynamic>).length;
  }

  Future<TradeHistoryModel> addTrade({
    required String instrument,
    required String direction,
    required bool isPaperTrade,
    String? strategyId,
    String? symbol,
    String? tradingMode,
    int? aiScore,
    double? entryPrice,
    double? stopLoss,
    double? targetPrice,
    double? riskRewardRatio,
    String status = 'executed',
    String? broker,
    String? brokerOrderId,
    DateTime? executedAt,
  }) async {
    final user = _currentUser;

    final data = <String, dynamic>{
      'user_id': user.id,
      'strategy_id': strategyId,
      'instrument': instrument,
      'symbol': symbol,
      'direction': direction,
      'trading_mode': tradingMode,
      'ai_score': aiScore,
      'entry_price': entryPrice,
      'stop_loss': stopLoss,
      'target_price': targetPrice,
      'risk_reward_ratio': riskRewardRatio,
      'status': status,
      'is_paper_trade': isPaperTrade,
      'broker': broker,
      'broker_order_id': brokerOrderId,
      'executed_at': (executedAt ?? DateTime.now()).toUtc().toIso8601String(),
    };

    final response = await _supabase
        .from(_table)
        .insert(data)
        .select()
        .single();

    return TradeHistoryModel.fromMap(Map<String, dynamic>.from(response));
  }
}
