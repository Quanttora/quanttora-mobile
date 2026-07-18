import '../../../core/broker/broker_account.dart';
import '../../../core/broker/broker_order.dart';
import '../../../core/broker/broker_position.dart';
import '../../../core/broker/broker_response.dart';
import '../core/broker_adapter.dart';
import 'upstox_auth_service.dart';

class UpstoxAdapter implements BrokerAdapter {
  final UpstoxAuthService _authService = UpstoxAuthService();

  @override
  String get brokerName => 'Upstox';

  @override
  Future<BrokerResponse<bool>> connect() async {
    return login();
  }

  @override
  Future<BrokerResponse<bool>> disconnect() async {
    throw UnimplementedError();
  }

  @override
  Future<BrokerResponse<bool>> login() async {
    final result = await _authService.login();

    print('OAuth Result: $result');

    throw UnimplementedError();
  }

  @override
  Future<BrokerResponse<bool>> logout() async {
    throw UnimplementedError();
  }

  @override
  Future<BrokerResponse<BrokerAccount>> fetchAccount() async {
    throw UnimplementedError();
  }

  @override
  Future<BrokerResponse<List<BrokerPosition>>> fetchPositions() async {
    throw UnimplementedError();
  }

  @override
  Future<BrokerResponse<List<BrokerOrder>>> fetchOrders() async {
    throw UnimplementedError();
  }

  @override
  Future<BrokerResponse<String>> placeOrder(BrokerOrder order) async {
    throw UnimplementedError();
  }

  @override
  Future<BrokerResponse<bool>> modifyOrder(
    String orderId,
    BrokerOrder order,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<BrokerResponse<bool>> cancelOrder(String orderId) async {
    throw UnimplementedError();
  }

  @override
  Future<BrokerResponse<double>> getLTP(String symbol) async {
    throw UnimplementedError();
  }
}