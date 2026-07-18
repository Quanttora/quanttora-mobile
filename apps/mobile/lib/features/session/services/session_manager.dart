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

  void updateStrategy(String strategy) {
    _session = _session.copyWith(
      strategy: strategy,
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
}