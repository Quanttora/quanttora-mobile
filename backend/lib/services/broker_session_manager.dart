import 'package:backend/models/broker_session.dart';

class BrokerSessionManager {
  BrokerSessionManager._();

  static final BrokerSessionManager instance =
      BrokerSessionManager._();

  BrokerSession? _session;

  bool get isConnected => _session != null;

  BrokerSession? get session => _session;

  void saveSession(BrokerSession session) {
    _session = session;
  }

  void clearSession() {
    _session = null;
  }
}