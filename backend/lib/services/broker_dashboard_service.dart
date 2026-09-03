import 'broker_market_service.dart';
import 'broker_service.dart';

class BrokerDashboardService {
  BrokerDashboardService._();

  static final BrokerDashboardService instance = BrokerDashboardService._();

  final BrokerService _brokerService = BrokerService.instance;

  Future<Map<String, dynamic>> getDashboard({required int userId}) async {
    final session = _brokerService.sessionForUser(userId);

    if (session == null) {
      throw Exception('No broker connected for authenticated user');
    }

    final token = _brokerService.accessTokenForUser(userId);
    final broker = BrokerMarketService.instance.current;

    print('');
    print('========================================');
    print('BROKER DASHBOARD REQUEST');
    print('QUANTTORA USER ID: $userId');
    print('BROKER: ${session.broker}');
    print('UPSTOX USER ID: ${session.userId}');
    print('========================================');

    final funds = await _safeCall(
      name: 'FUNDS',
      call: () => broker.getFunds(token),
    );

    final holdings = await _safeCall(
      name: 'HOLDINGS',
      call: () => broker.getHoldings(token),
    );

    final positions = await _safeCall(
      name: 'POSITIONS',
      call: () => broker.getPositions(token),
    );

    final orders = await _safeCall(
      name: 'ORDERS',
      call: () => broker.getOrderBook(token),
    );

    final trades = await _safeCall(
      name: 'TRADES',
      call: () => broker.getTradeBook(token),
    );

    print('========================================');
    print('BROKER DASHBOARD COMPLETE');
    print('========================================');
    print('');

    double availableMargin = 0;
    double usedMargin = 0;

    final fundsData = funds['data'];

    if (fundsData is Map) {
      final equity = fundsData['equity'];

      if (equity is Map) {
        availableMargin = _toDouble(equity['available_margin']);

        usedMargin = _toDouble(equity['used_margin']);
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

      'funds': funds['data'],

      'holdings': holdings['data'],
      'positions': positions['data'],
      'orders': orders['data'],
      'trades': trades['data'],

      'apiStatus': {
        'funds': funds['success'],
        'holdings': holdings['success'],
        'positions': positions['success'],
        'orders': orders['success'],
        'trades': trades['success'],
      },

      'apiErrors': {
        'funds': funds['error'],
        'holdings': holdings['error'],
        'positions': positions['error'],
        'orders': orders['error'],
        'trades': trades['error'],
      },
    };
  }

  Future<Map<String, dynamic>> _safeCall({
    required String name,
    required Future<Map<String, dynamic>> Function() call,
  }) async {
    try {
      print('[Broker Dashboard] Calling $name...');

      final result = await call();

      print('[Broker Dashboard] $name SUCCESS');

      return {
        'success': true,
        'data': result['data'],
        'raw': result,
        'error': null,
      };
    } catch (e) {
      print('[Broker Dashboard] $name FAILED: $e');

      return {
        'success': false,
        'data': null,
        'raw': null,
        'error': e.toString(),
      };
    }
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
