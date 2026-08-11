import 'package:backend/interfaces/broker/broker_market_feed_interface.dart';
import 'package:backend/services/broker_service.dart';
import 'package:backend/services/upstox_market_feed.dart';

class BrokerMarketFeedService {
  BrokerMarketFeedService._();

  static final BrokerMarketFeedService instance =
      BrokerMarketFeedService._();

  BrokerMarketFeedInterface get current {
    final broker =
        BrokerService.instance.session?.broker;

    switch (broker?.toLowerCase()) {
      case 'upstox':
        return UpstoxMarketFeed.instance;

      default:
        throw UnsupportedError(
          'Market feed is not supported for broker: $broker',
        );
    }
  }

  bool get isSupported {
    final broker =
        BrokerService.instance.session?.broker;

    switch (broker?.toLowerCase()) {
      case 'upstox':
        return true;

      default:
        return false;
    }
  }
}