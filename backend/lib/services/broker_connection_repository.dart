import 'package:backend/models/broker_connection.dart';

class BrokerConnectionRepository {
  static final Map<String, BrokerConnection> _connections = {};

  void save(BrokerConnection connection) {
    _connections[connection.userId] = connection;
  }

  BrokerConnection? findByUserId(String userId) {
    return _connections[userId];
  }

  List<BrokerConnection> getAll() {
    return _connections.values.toList();
  }

  void clear() {
    _connections.clear();
  }
}