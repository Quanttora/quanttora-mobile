import 'package:backend/models/broker_session.dart';
import 'package:backend/services/broker_session_manager.dart';

class BrokerService {
  BrokerService._();

  static final BrokerService instance = BrokerService._();

  final BrokerSessionManager _manager =
      BrokerSessionManager.instance;

  void connect(BrokerSession session) {
    _manager.saveSession(session);
  }

  void disconnect() {
    _manager.clearSession();
  }

  bool get isConnected => _manager.isConnected;

  BrokerSession? get session => _manager.session;
}