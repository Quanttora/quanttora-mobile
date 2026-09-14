import 'package:backend/models/broker_session.dart';
import 'package:backend/services/broker_connection_repository.dart';
import 'package:backend/services/broker_service.dart';
import 'package:backend/services/upstox_market_feed.dart';

class BrokerStartupService {
  BrokerStartupService._();

  static final BrokerStartupService instance = BrokerStartupService._();

  final BrokerConnectionRepository _repository =
      BrokerConnectionRepository();

  Future<void> restore() async {
    final connections = await _repository.getAll();

    if (connections.isEmpty) {
      print('[Broker Startup] No persisted broker connection found.');
      return;
    }

    final connection = connections.first;

    final accessToken = connection['accessToken'] as String;
    final refreshToken = connection['refreshToken'] as String? ?? '';
    final accessTokenExpiresAt =
        connection['accessTokenExpiresAt'] as DateTime?;

    final session = BrokerSession(
      broker: connection['broker'] as String,
      userId: connection['brokerUserId'] as String,
      userName: connection['userName'] as String,
      email: connection['email'] as String,
      accessToken: accessToken,
      refreshToken: refreshToken.isEmpty ? null : refreshToken,
      connectedAt: DateTime.now().toUtc(),
      accessTokenExpiresAt: accessTokenExpiresAt,
    );

    BrokerService.instance.connectForUser(
  userId: connection['userId'] as int,
  session: session,
);

    print(
      '[Broker Startup] Restored broker session '
      'for Quanttora user ${connection['userId']}.',
    );

    print(
      '[Broker Startup] Access token expiry: '
      '${accessTokenExpiresAt?.toUtc().toIso8601String() ?? 'not persisted'}.',
    );

    print(
      '[Broker Startup] Refresh token: '
      '${refreshToken.isNotEmpty ? 'present' : 'not persisted'}.',
    );

    try {
      await UpstoxMarketFeed.instance.connect();

      print(
        '[Broker Startup] Upstox market feed connected. '
        'Subscribed ${UpstoxMarketFeed.instance.subscriptions.length} instruments.',
      );
    } catch (error) {
      print(
        '[Broker Startup] Unable to reconnect Upstox market feed: $error',
      );
    }
  }
}