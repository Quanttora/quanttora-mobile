import 'broker_market_service.dart';
import 'broker_service.dart';

class BrokerDashboardService {
  BrokerDashboardService._();

  static final BrokerDashboardService instance =
      BrokerDashboardService._();

  final BrokerService _brokerService =
      BrokerService.instance;

  Future<Map<String, dynamic>> getDashboard() async {
    final session = _brokerService.session;

    if (session == null) {
      throw Exception('No broker connected');
    }

    final token = session.accessToken;
    final broker = BrokerMarketService.instance.current;

    final results = await Future.wait([
      broker.getFunds(token),
      broker.getHoldings(token),
      broker.getPositions(token),
      broker.getOrderBook(token),
      broker.getTradeBook(token),
    ]);

    final funds = results[0];

    double availableMargin = 0;
    double usedMargin = 0;

    final fundsData = funds['data'];

    if (fundsData is Map<String, dynamic>) {
      final equity = fundsData['equity'];

      if (equity is Map<String, dynamic>) {
        availableMargin =
            _toDouble(equity['available_margin']);

        usedMargin =
            _toDouble(equity['used_margin']);
      }
    }

    return {
      'connected': true,
      'broker': session.broker,

      'user': {
        'name': session.userName,
        'email': session.email,
        'userId': session.userId,
      },

      'userName': session.userName,
      'email': session.email,
      'userId': session.userId,

      'availableMargin': availableMargin,
      'usedMargin': usedMargin,

      'funds': funds,
      'holdings': results[1],
      'positions': results[2],
      'orders': results[3],
      'trades': results[4],
    };
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}