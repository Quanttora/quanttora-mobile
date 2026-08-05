import '../../core/broker/broker_account.dart';
import '../../core/broker/broker_order.dart';
import '../../core/broker/broker_position.dart';
import '../../core/broker/broker_response.dart';

abstract class BrokerAdapter {
  String get brokerName;

  Future<BrokerResponse<bool>> connect();

  Future<BrokerResponse<bool>> disconnect();

  Future<BrokerResponse<bool>> login();

  Future<BrokerResponse<bool>> logout();

  Future<BrokerResponse<BrokerAccount>> fetchAccount();

  Future<BrokerResponse<List<BrokerPosition>>> fetchPositions();

  Future<BrokerResponse<List<BrokerOrder>>> fetchOrders();

  Future<BrokerResponse<String>> placeOrder(BrokerOrder order);

  Future<BrokerResponse<bool>> modifyOrder(String orderId, BrokerOrder order);

  Future<BrokerResponse<bool>> cancelOrder(String orderId);

  Future<BrokerResponse<double>> getLTP(String symbol);
}
