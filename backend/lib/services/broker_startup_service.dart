import 'package:backend/models/broker_session.dart';
import 'package:backend/services/broker_connection_repository.dart';
import 'package:backend/services/broker_service.dart';
import 'package:backend/services/upstox_market_feed.dart';

class BrokerStartupService {
  BrokerStartupService._();

  static final BrokerStartupService instance =
      BrokerStartupService._();

  final BrokerConnectionRepository _repository =
      BrokerConnectionRepository();

  final BrokerService _brokerService =
      BrokerService.instance;

  final UpstoxMarketFeed _marketFeed =
      UpstoxMarketFeed.instance;

  static const List<String> _marketInstruments = [
    'NSE_INDEX|Nifty 50',
    'NSE_INDEX|Nifty Bank',
    'BSE_INDEX|SENSEX',
    'NSE_INDEX|India VIX',
    'NSE_INDEX|Nifty Auto',
    'NSE_INDEX|Nifty FMCG',
    'NSE_INDEX|Nifty IT',
    'NSE_INDEX|Nifty Metal',
    'NSE_INDEX|Nifty Pharma',
    'NSE_INDEX|Nifty PSU Bank',
    'NSE_INDEX|Nifty Realty',
    'NSE_EQ|INE002A01018',
    'NSE_EQ|INE467B01029',
    'NSE_EQ|INE040A01034',
    'NSE_EQ|INE009A01021',
    'NSE_EQ|INE090A01021',
    'NSE_EQ|INE062A01020',
    'NSE_EQ|INE397D01024',
    'NSE_EQ|INE154A01025',
  ];

  Future<void> restore() async {
    final connections = await _repository.getAll();

    if (connections.isEmpty) {
      print('[Broker Startup] No persisted broker connections.');
      return;
    }

    for (final connection in connections) {
      final quanttoraUserId = connection['userId'];

      if (quanttoraUserId is! int) {
        print(
          '[Broker Startup] Invalid Quanttora user ID. '
          'Skipping connection.',
        );
        continue;
      }

      final accessToken =
          connection['accessToken']?.toString() ?? '';

      if (accessToken.isEmpty) {
        print(
          '[Broker Startup] Missing Upstox access token. '
          'Skipping user $quanttoraUserId.',
        );
        continue;
      }

      final session = BrokerSession(
        broker: connection['broker']?.toString() ?? 'Upstox',
        userId:
            connection['brokerUserId']?.toString() ?? '',
        userName:
            connection['userName']?.toString() ?? '',
        email:
            connection['email']?.toString() ?? '',
        accessToken: accessToken,
        refreshToken: null,
        connectedAt: DateTime.now().toUtc(),
        accessTokenExpiresAt: null,
      );

      if (!session.hasValidAccessToken) {
        print(
          '[Broker Startup] Persisted Upstox token is invalid '
          'for user $quanttoraUserId.',
        );
        continue;
      }

      _brokerService.connectForUser(
        userId: quanttoraUserId,
        session: session,
      );

      print(
        '[Broker Startup] Restored broker session '
        'for Quanttora user $quanttoraUserId.',
      );

      try {
        await _marketFeed.connect();

        await _marketFeed.subscribeMany(
          _marketInstruments,
        );

        print(
          '[Broker Startup] Upstox market feed connected. '
          'Subscribed ${_marketInstruments.length} instruments.',
        );
      } catch (e, stackTrace) {
        print(
          '[Broker Startup] Market feed restoration failed: $e',
        );
        print(stackTrace);
      }

      break;
    }
  }
}