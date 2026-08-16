import 'package:backend/models/broker_session.dart';
import 'package:backend/services/broker_session_manager.dart';

class BrokerService {
  BrokerService._();

  static final BrokerService instance = BrokerService._();

  final BrokerSessionManager _sessionManager = BrokerSessionManager.instance;

  BrokerSession? get session => _sessionManager.session;

  bool get isConnected => _sessionManager.isConnected;

  void connect(BrokerSession session) {
    _sessionManager.saveSession(session);
  }

  void disconnect() {
    _sessionManager.clearSession();
  }

  void update(BrokerSession session) {
    _sessionManager.updateSession(session);
  }

  bool hasValidSession() {
    final current = session;

    if (current == null) {
      return false;
    }

    return current.hasValidAccessToken;
  }

  String get accessToken {
    final current = session;

    if (current == null) {
      throw StateError('Broker is not connected.');
    }

    if (!current.hasValidAccessToken) {
      throw StateError(
        'Upstox access token has expired. '
        'Please reconnect your broker.',
      );
    }

    return current.accessToken;
  }

  String get broker {
    final current = session;

    if (current == null) {
      throw StateError('Broker is not connected.');
    }

    return current.broker;
  }

  String get userId {
    final current = session;

    if (current == null) {
      throw StateError('Broker is not connected.');
    }

    return current.userId;
  }

  String get userName {
    final current = session;

    if (current == null) {
      throw StateError('Broker is not connected.');
    }

    return current.userName;
  }

  String get email {
    final current = session;

    if (current == null) {
      throw StateError('Broker is not connected.');
    }

    return current.email;
  }

  DateTime? get accessTokenExpiresAt => session?.accessTokenExpiresAt;

  bool get isAccessTokenExpired => session?.isAccessTokenExpired ?? true;
}
