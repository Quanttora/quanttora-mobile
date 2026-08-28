import '../models/broker_session.dart';

class BrokerSessionManager {
  BrokerSessionManager._();

  static final BrokerSessionManager instance = BrokerSessionManager._();

  final Map<int, BrokerSession> _sessions = {};

  /// Read-only view of all active broker sessions.
  ///
  /// This is primarily used by BrokerService's legacy compatibility API.
  Map<int, BrokerSession> get sessions {
    return Map.unmodifiable(_sessions);
  }

  /// Returns the broker session for a specific Quanttora user.
  BrokerSession? sessionForUser(int userId) {
    return _sessions[userId];
  }

  /// Saves a broker session for a specific Quanttora user.
  void saveSessionForUser({
    required int userId,
    required BrokerSession session,
  }) {
    if (session.accessToken.isEmpty) {
      throw ArgumentError(
        'Cannot save broker session without an access token.',
      );
    }

    _sessions[userId] = session;
  }

  /// Updates the broker session for a specific Quanttora user.
  void updateSessionForUser({
    required int userId,
    required BrokerSession session,
  }) {
    saveSessionForUser(userId: userId, session: session);
  }

  /// Clears only one user's broker session.
  void clearSessionForUser(int userId) {
    _sessions.remove(userId);
  }

  /// Returns whether a user currently has a connected broker session.
  bool isConnectedForUser(int userId) {
    final session = _sessions[userId];

    return session != null && session.accessToken.isNotEmpty;
  }

  /// Returns the access token for a specific user.
  String accessTokenForUser(int userId) {
    final session = sessionForUser(userId);

    if (session == null || session.accessToken.isEmpty) {
      throw StateError('Broker is not connected.');
    }

    return session.accessToken;
  }

  /// Returns whether a user has a valid, non-expired broker session.
  bool hasValidSessionForUser(int userId) {
    final session = sessionForUser(userId);

    return session != null && session.hasValidAccessToken;
  }

  /// Clears all broker sessions.
  ///
  /// This is intended for application shutdown/reset operations.
  /// User-facing disconnect operations should use clearSessionForUser().
  void clearAllSessions() {
    _sessions.clear();
  }

  /// Number of currently connected Quanttora users.
  int get connectedUserCount {
    return _sessions.length;
  }
}
