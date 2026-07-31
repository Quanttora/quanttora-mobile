import 'package:backend/models/broker_session.dart';

class BrokerService {
  BrokerService._();

  static final BrokerService instance = BrokerService._();

  BrokerSession? _session;

  BrokerSession? get session => _session;

  bool get isConnected => _session != null;

  void connect(BrokerSession session) {
    _session = session;
  }

  void disconnect() {
    _session = null;
  }

  void update(BrokerSession session) {
    _session = session;
  }

  bool hasValidSession() {
    return _session != null &&
        _session!.accessToken.isNotEmpty;
  }

  String get accessToken {
    if (_session == null) {
      throw StateError(
        'Broker is not connected.',
      );
    }

    return _session!.accessToken;
  }

  String get broker {
    if (_session == null) {
      throw StateError(
        'Broker is not connected.',
      );
    }

    return _session!.broker;
  }

  String get userId {
    if (_session == null) {
      throw StateError(
        'Broker is not connected.',
      );
    }

    return _session!.userId;
  }

  String get userName {
    if (_session == null) {
      throw StateError(
        'Broker is not connected.',
      );
    }

    return _session!.userName;
  }

  String get email {
    if (_session == null) {
      throw StateError(
        'Broker is not connected.',
      );
    }

    return _session!.email;
  }
}