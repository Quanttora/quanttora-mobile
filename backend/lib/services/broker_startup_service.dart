import 'package:backend/models/broker_session.dart';
import 'package:backend/services/broker_connection_repository.dart';
import 'package:backend/services/broker_service.dart';
import 'package:backend/services/upstox_market_feed.dart';
import 'package:backend/services/zerodha_market_feed.dart';

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

    /*
     * Prefer Zerodha only when the persisted access token has
     * an explicit, non-expired expiry time.
     *
     * Zerodha access tokens are session-based and the expiry must
     * never be assumed when it was not persisted.
     */
    Map<String, dynamic>? connection;

    for (final item in connections) {
      final broker =
          (item['broker'] as String? ?? '').trim().toLowerCase();

      if (!_isZerodha(broker)) {
        continue;
      }

      final accessToken =
          (item['accessToken'] as String? ?? '').trim();

      final expiry =
          item['accessTokenExpiresAt'] as DateTime?;

      final isValid =
          accessToken.isNotEmpty &&
          expiry != null &&
          expiry.isAfter(DateTime.now().toUtc());

      if (isValid) {
        connection = item;
        break;
      }

      print(
        '[Broker Startup] Ignoring persisted Zerodha session because '
        'the access token is expired or its expiry is not persisted.',
      );
    }

    /*
     * If no valid Zerodha connection exists, look for a valid
     * Upstox connection.
     */
    connection ??= _findValidConnection(
      connections,
      preferredBroker: 'upstox',
    );

    if (connection == null) {
      print(
        '[Broker Startup] No valid persisted broker session found.',
      );
      print(
        '[Broker Startup] Existing broker tokens may have expired. '
        'A new broker login is required.',
      );
      return;
    }

    final broker =
        (connection['broker'] as String? ?? '').trim();

    final accessToken =
        (connection['accessToken'] as String? ?? '').trim();

    final refreshToken =
        (connection['refreshToken'] as String? ?? '').trim();

    final accessTokenExpiresAt =
        connection['accessTokenExpiresAt'] as DateTime?;

    final userId =
        connection['userId'] as int;

    final session = BrokerSession(
      broker: broker,
      userId: connection['brokerUserId'] as String,
      userName: connection['userName'] as String,
      email: connection['email'] as String,
      accessToken: accessToken,
      refreshToken:
          refreshToken.isEmpty ? null : refreshToken,
      connectedAt: DateTime.now().toUtc(),
      accessTokenExpiresAt: accessTokenExpiresAt,
    );

    BrokerService.instance.connectForUser(
      userId: userId,
      session: session,
    );

    print(
      '[Broker Startup] Restored $broker session '
      'for Quanttora user $userId.',
    );

    print(
      '[Broker Startup] Access token expiry: '
      '${accessTokenExpiresAt?.toUtc().toIso8601String() ?? 'not persisted'}.',
    );

    print(
      '[Broker Startup] Refresh token: '
      '${refreshToken.isNotEmpty ? 'present' : 'not persisted'}.',
    );

    /*
     * Zerodha currently uses REST API integration in Quanttora.
     * Do NOT start the Upstox websocket/feed for Zerodha.
     */
        if (_isZerodha(broker)) {
      try {
        await ZerodhaMarketFeed.instance.connect(accessToken: accessToken);
        print('[Broker Startup] Zerodha live WebSocket connected.');
      } catch (error) {
        print('[Broker Startup] Zerodha live WebSocket could not connect: $error');
      }
      return;
    }


    /*
     * Only Upstox should start the Upstox market feed.
     */
    if (_isUpstox(broker)) {
      try {
        await UpstoxMarketFeed.instance.connect();

        print(
          '[Broker Startup] Upstox market feed connected. '
          'Subscribed '
          '${UpstoxMarketFeed.instance.subscriptions.length} '
          'instruments.',
        );
      } catch (error) {
        print(
          '[Broker Startup] Unable to reconnect '
          'Upstox market feed: $error',
        );
      }

      return;
    }

    print(
      '[Broker Startup] Broker "$broker" restored without '
      'starting a broker-specific market feed.',
    );
  }

  Map<String, dynamic>? _findValidConnection(
    List<Map<String, dynamic>> connections, {
    required String preferredBroker,
  }) {
    for (final connection in connections) {
      final broker =
          (connection['broker'] as String? ?? '')
              .trim()
              .toLowerCase();

      if (broker != preferredBroker) {
        continue;
      }

      final accessToken =
          (connection['accessToken'] as String? ?? '').trim();

      final expiry =
          connection['accessTokenExpiresAt'] as DateTime?;

      final isValid =
          accessToken.isNotEmpty &&
          (expiry == null ||
              expiry.isAfter(DateTime.now().toUtc()));

      if (isValid) {
        return connection;
      }
    }

    return null;
  }

  bool _isZerodha(String broker) {
    final value = broker.toLowerCase();

    return value == 'zerodha' ||
        value == 'zerodha kite' ||
        value == 'kite';
  }

  bool _isUpstox(String broker) {
    return broker.toLowerCase() == 'upstox';
  }
}
