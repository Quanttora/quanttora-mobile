import '../../strategy/models/strategy_model.dart';
import '../models/trade_session.dart';

class SessionManager {
  SessionManager._();

  static final SessionManager instance = SessionManager._();

  TradeSession _session = TradeSession();

  TradeSession get session => _session;

  void updateBroker(String broker) {
    _session = _session.copyWith(
      broker: broker,
    );
  }

  void updateInstrument(String instrument) {
    _session = _session.copyWith(
      instrument: instrument,
    );
  }

  void updateTradingMode(String mode) {
    _session = _session.copyWith(
      tradingMode: mode,
    );
  }

  /// Legacy strategy-name update.
  ///
  /// Kept temporarily so existing screens continue to compile while
  /// Quanttora is migrated to StrategyModel-based selection.
  void updateStrategy(String strategy) {
    _session = _session.copyWith(
      strategy: strategy,
    );
  }

  /// Select a complete Quanttora strategy for the current trading session.
  void selectStrategy(StrategyModel strategy) {
    _session = _session.copyWith(
      strategyId: strategy.id,
      strategy: strategy.name,
      strategyTimeframe: strategy.timeframe,
      strategyInstruments: List<String>.from(
        strategy.instruments,
      ),
      strategyMinimumAiScore: strategy.minimumAiScore,
      strategyRiskRewardRatio: strategy.riskRewardRatio,
      strategyMaxTradesPerDay: strategy.maxTradesPerDay,
      strategyAvoidNews: strategy.avoidNews,
      strategyAvoidSideways: strategy.avoidSideways,
      strategyAvoidLowVolume: strategy.avoidLowVolume,
      riskReward:
          '1:${_formatRatio(strategy.riskRewardRatio)}',
    );
  }

  void updateRisk({
    required double riskPercent,
    required String riskReward,
  }) {
    _session = _session.copyWith(
      riskPercent: riskPercent,
      riskReward: riskReward,
    );
  }

  void enablePaperTrade(bool value) {
    _session = _session.copyWith(
      paperTrade: value,
    );
  }

  void clear() {
    _session = TradeSession();
  }

  static String _formatRatio(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }
}