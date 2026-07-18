import '../core/broker_adapter.dart';
import '../../../core/broker/broker_account.dart';
import '../../../core/broker/broker_order.dart';
import '../../../core/broker/broker_position.dart';
import '../../../core/broker/broker_response.dart';

class UpstoxAdapter implements BrokerAdapter {
  @override
  String get brokerName => 'Upstox';

  @override
  Future<BrokerResponse<bool>> connect() {
    throw UnimplementedError();
  }

  @override
  Future<BrokerResponse<bool>> disconnect() {
    throw UnimplementedError();
  }

  @override
  Future<BrokerResponse<bool>> login() {
    throw UnimplementedError();
  }

  @override
  Future<BrokerResponse<bool>> logout() {
    throw UnimplementedError();
  }

  @override
  Future<BrokerResponse<BrokerAccount>> fetchAccount() {
    throw UnimplementedError();
  }

  @override
  Future<BrokerResponse<List<BrokerPosition>>> fetchPositions() {
    throw UnimplementedError();
  }

  @override
  Future<BrokerResponse<List<BrokerOrder>>> fetchOrders() {
    throw UnimplementedError();
  }

  @override
  Future<BrokerResponse<String>> placeOrder(BrokerOrder order) {
    throw UnimplementedError();
  }

  @override
  Future<BrokerResponse<bool>> modifyOrder(
    String orderId,
    BrokerOrder order,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<BrokerResponse<bool>> cancelOrder(String orderId) {
    throw UnimplementedError();
  }

  @override
  Future<BrokerResponse<double>> getLTP(String symbol) {
    throw UnimplementedError();
  }
}