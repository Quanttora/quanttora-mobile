import '../integrations/upstox/upstox_broker_service.dart';
import 'broker_service.dart';

class BrokerDashboardService {
  BrokerDashboardService._();

  static final BrokerDashboardService instance =
      BrokerDashboardService._();

  final BrokerService _brokerService = BrokerService.instance;
  final UpstoxBrokerService _broker = UpstoxBrokerService();

  Future<Map<String, dynamic>> getDashboard() async {
    final session = _brokerService.session;

    if (session == null) {
      throw Exception('No broker connected');
    }

    final token = session.accessToken;

    final results = await Future.wait([
      _broker.getFunds(token),
      _broker.getHoldings(token),
      _broker.getPositions(token),
      _broker.getOrderBook(token),
      _broker.getTradeBook(token),
    ]);

    return {
      "connected": true,
      "broker": session.broker,
      "user": {
        "name": session.userName,
        "email": session.email,
        "userId": session.userId,
      },
      "funds": results[0],
      "holdings": results[1],
      "positions": results[2],
      "orders": results[3],
      "trades": results[4],
    };
  }
}