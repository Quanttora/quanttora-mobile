import '../models/broker_session.dart';
import 'broker_session_manager.dart';

class BrokerService {
  BrokerService._();

  static final BrokerService instance = BrokerService._();

  final BrokerSessionManager _sessionManager = BrokerSessionManager.instance;

  // ---------------------------------------------------------------------------
  // Legacy compatibility API
  //
  // These methods/getters are retained because several existing backend
  // services still use the original BrokerService singleton API.
  // ---------------------------------------------------------------------------

  BrokerSession? get session {
    final sessions = _sessionManager.sessions;

    if (sessions.isEmpty) {
      return null;
    }

    return sessions.values.first;
  }

  bool get isConnected {
    final current = session;

    return current != null && current.accessToken.isNotEmpty;
  }

  String get accessToken {
    final current = session;

    if (current == null || current.accessToken.isEmpty) {
      throw StateError('Broker is not connected.');
    }

    return current.accessToken;
  }

  bool hasValidSession() {
    final current = session;

    return current != null && current.hasValidAccessToken;
  }

  void connect(BrokerSession session) {
    final userId = int.tryParse(session.userId);

    if (userId == null) {
      throw ArgumentError(
        'Broker session userId must contain a valid Quanttora user ID.',
      );
    }

    _sessionManager.saveSessionForUser(userId: userId, session: session);
  }

  void update(BrokerSession session) {
    final userId = int.tryParse(session.userId);

    if (userId == null) {
      throw ArgumentError(
        'Broker session userId must contain a valid Quanttora user ID.',
      );
    }

    _sessionManager.updateSessionForUser(userId: userId, session: session);
  }

  void disconnect() {
    final current = session;

    if (current == null) {
      return;
    }

    final userId = int.tryParse(current.userId);

    if (userId != null) {
      _sessionManager.clearSessionForUser(userId);
    }
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

  DateTime? get accessTokenExpiresAt {
    return session?.accessTokenExpiresAt;
  }

  bool get isAccessTokenExpired {
    return session?.isAccessTokenExpired ?? true;
  }

  // ---------------------------------------------------------------------------
  // User-scoped API
  // ---------------------------------------------------------------------------

  BrokerSession? sessionForUser(int userId) {
    return _sessionManager.sessionForUser(userId);
  }

  bool isConnectedForUser(int userId) {
    return _sessionManager.isConnectedForUser(userId);
  }

  void connectForUser({required int userId, required BrokerSession session}) {
    _sessionManager.saveSessionForUser(userId: userId, session: session);
  }

  void disconnectForUser(int userId) {
    _sessionManager.clearSessionForUser(userId);
  }

  void updateForUser({required int userId, required BrokerSession session}) {
    _sessionManager.updateSessionForUser(userId: userId, session: session);
  }

  bool hasValidSessionForUser(int userId) {
    return _sessionManager.hasValidSessionForUser(userId);
  }

  String accessTokenForUser(int userId) {
    return _sessionManager.accessTokenForUser(userId);
  }

  String brokerForUser(int userId) {
    final current = sessionForUser(userId);

    if (current == null) {
      throw StateError('Broker is not connected.');
    }

    return current.broker;
  }

  String userIdForUser(int userId) {
    final current = sessionForUser(userId);

    if (current == null) {
      throw StateError('Broker is not connected.');
    }

    return current.userId;
  }

  String userNameForUser(int userId) {
    final current = sessionForUser(userId);

    if (current == null) {
      throw StateError('Broker is not connected.');
    }

    return current.userName;
  }

  String emailForUser(int userId) {
    final current = sessionForUser(userId);

    if (current == null) {
      throw StateError('Broker is not connected.');
    }

    return current.email;
  }

  DateTime? accessTokenExpiresAtForUser(int userId) {
    return sessionForUser(userId)?.accessTokenExpiresAt;
  }

  bool isAccessTokenExpiredForUser(int userId) {
    return sessionForUser(userId)?.isAccessTokenExpired ?? true;
  }

  int get connectedUserCount {
    return _sessionManager.connectedUserCount;
  }
}
