import 'package:backend/models/broker_session.dart';

class BrokerSessionManager {
  BrokerSessionManager._();

  static final BrokerSessionManager instance = BrokerSessionManager._();

  BrokerSession? _session;

  BrokerSession? get session => _session;

  bool get isConnected => _session != null && _session!.accessToken.isNotEmpty;

  String get accessToken {
    final current = _session;

    if (current == null || current.accessToken.isEmpty) {
      throw StateError('Broker is not connected.');
    }

    return current.accessToken;
  }

  void saveSession(BrokerSession session) {
    if (session.accessToken.isEmpty) {
      throw ArgumentError(
        'Cannot save broker session without an access token.',
      );
    }

    _session = session;
  }

  void updateSession(BrokerSession session) {
    saveSession(session);
  }

  void clearSession() {
    _session = null;
  }

  bool hasValidSession() {
    return isConnected;
  }
}
