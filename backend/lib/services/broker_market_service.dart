import 'package:backend/interfaces/broker_market_interface.dart';
import 'package:backend/integrations/upstox/upstox_broker_service.dart';
import 'package:backend/services/broker_service.dart';

class BrokerMarketService {
  BrokerMarketService._();

  static final BrokerMarketService instance =
      BrokerMarketService._();

  final BrokerService _brokerService =
      BrokerService.instance;

  BrokerMarketInterface get current {
    final session = _brokerService.session;

    if (session == null) {
      throw StateError('No broker connected.');
    }

    switch (session.broker.toLowerCase()) {
      case 'upstox':
        return UpstoxBrokerService();

      default:
        throw UnsupportedError(
          'Broker "${session.broker}" is not supported yet.',
        );
    }
  }

  String get brokerName {
    final session = _brokerService.session;

    if (session == null) {
      throw StateError('No broker connected.');
    }

    return session.broker;
  }

  bool get isSupported {
    final broker = brokerName.toLowerCase();

    return broker == 'upstox';
  }
}