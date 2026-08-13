import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:backend/generated/market_data_v3.pb.dart';
import 'package:backend/interfaces/broker/broker_market_feed_interface.dart';
import 'package:backend/models/broker_session.dart';
import 'package:backend/services/broker_service.dart';
import 'package:backend/services/market_cache_service.dart';
import 'package:http/http.dart' as http;

class UpstoxMarketFeed
    implements BrokerMarketFeedInterface {
  UpstoxMarketFeed._();

  static final UpstoxMarketFeed instance =
      UpstoxMarketFeed._();

  static const String _authorizeUrl =
      'https://api.upstox.com/v3/feed/market-data-feed/authorize';

  WebSocket? _socket;

  Timer? _pingTimer;
  Timer? _reconnectTimer;

  bool _connecting = false;
  bool _connected = false;

  int _reconnectAttempt = 0;

  final Set<String> _subscriptions = {};

  final StreamController<FeedResponse> _controller =
      StreamController<FeedResponse>.broadcast();

  Stream<FeedResponse> get stream =>
      _controller.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<void> connect() async {
    if (_connecting || _connected) {
      return;
    }

    _connecting = true;

    try {
      final session =
          BrokerService.instance.session;

      if (session == null) {
        throw Exception(
          'Broker not connected.',
        );
      }

      final wsUrl =
          await _getAuthorizedWebSocketUrl(
        session,
      );

      await _connectSocket(wsUrl);

      _connecting = false;
      _connected = true;
      _reconnectAttempt = 0;

      _startHeartbeat();

      print('[Upstox Feed] Connected');
    } catch (e) {
      _connecting = false;
      _connected = false;

      print(
        '[Upstox Feed] Connection failed: $e',
      );

      _scheduleReconnect();
    }
  }

  @override
  Future<void> disconnect() async {
    _connected = false;

    _pingTimer?.cancel();
    _reconnectTimer?.cancel();

    await _socket?.close();

    _socket = null;
  }

  @override
  Future<void> subscribe(
    List<String> instruments,
  ) async {
    _subscriptions.addAll(instruments);

    if (!_connected) {
      print(
        '[Upstox Feed] Not connected. Subscription cached.',
      );
      return;
    }

    if (instruments.isEmpty) {
      return;
    }

    final payload = {
      'guid':
          DateTime.now()
              .millisecondsSinceEpoch
              .toString(),
      'method': 'sub',
      'data': {
        'mode': 'full',
        'instrumentKeys': instruments,
      },
    };

    final message =
        jsonEncode(payload);

    final binaryMessage =
        utf8.encode(message);

    print('');
    print('==============================');
    print('[Upstox Feed] SUBSCRIBE');
    print(message);
    print(
      '[Upstox Feed] Sending binary subscription '
      '(${binaryMessage.length} bytes)',
    );
    print('==============================');
    print('');

    _socket?.add(binaryMessage);

    print(
      '[Upstox Feed] Binary subscription sent',
    );
  }

  @override
  Future<void> unsubscribe(
    List<String> instruments,
  ) async {
    _subscriptions.removeAll(
      instruments,
    );

    if (!_connected ||
        instruments.isEmpty) {
      return;
    }

    final payload = {
      'guid':
          DateTime.now()
              .millisecondsSinceEpoch
              .toString(),
      'method': 'unsub',
      'data': {
        'instrumentKeys': instruments,
      },
    };

    final message =
        jsonEncode(payload);

    final binaryMessage =
        utf8.encode(message);

    _socket?.add(binaryMessage);

    print(
      '[Upstox Feed] Binary unsubscribe sent',
    );
  }

  Future<String> _getAuthorizedWebSocketUrl(
    BrokerSession session,
  ) async {
    final response = await http.get(
      Uri.parse(_authorizeUrl),
      headers: {
        'Authorization':
            'Bearer ${session.accessToken}',
        'Accept': '*/*',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Market feed authorization failed '
        '(${response.statusCode}): '
        '${response.body}',
      );
    }

    final decoded =
        jsonDecode(response.body);

    final data = decoded['data'];

    if (data is! Map) {
      throw Exception(
        'Invalid market feed authorization response.',
      );
    }

    final url =
        data['authorizedRedirectUri']
            ?.toString();

    if (url == null || url.isEmpty) {
      throw Exception(
        'Market feed WebSocket URL is missing.',
      );
    }

    return url;
  }

  Future<void> _connectSocket(
    String url,
  ) async {
    _socket =
        await WebSocket.connect(url);

    _socket!.pingInterval =
        const Duration(seconds: 20);

    _socket!.listen(
      _onMessage,
      onDone: _onDisconnected,
      onError: _onError,
      cancelOnError: true,
    );

    if (_subscriptions.isNotEmpty) {
      await subscribe(
        _subscriptions.toList(),
      );
    }
  }

  void _onMessage(
    dynamic message,
  ) {
    print('');
    print('==============================');
    print(
      '[Upstox Feed] MESSAGE RECEIVED',
    );

    try {
      if (message is! List<int>) {
        print(
          'Unexpected text message: $message',
        );
        print(
          'Expected binary protobuf feed message.',
        );
        print(
          '==============================',
        );
        return;
      }

      final response =
          FeedResponse.fromBuffer(
        message,
      );

      print(
        'Type        : ${response.type}',
      );

      print(
        'Timestamp   : ${response.currentTs}',
      );

      print(
        'Feeds Count : ${response.feeds.length}',
      );

      print(
        'Market Info : ${response.hasMarketInfo()}',
      );

      if (response.hasMarketInfo()) {
        print(
          'Segment Status : '
          '${response.marketInfo.segmentStatus}',
        );
      }

      if (response.feeds.isNotEmpty) {
        response.feeds.forEach(
          (key, value) {
            MarketCacheService.instance
                .update(
              key,
              value,
            );

            print(
              'Feed Received : $key',
            );
          },
        );

        _controller.add(
          response,
        );
      } else {
        print(
          'No feeds in this frame.',
        );
      }
    } catch (e, s) {
      print('Decode Error');
      print(e);
      print(s);
    }

    print(
      '==============================',
    );
  }

  void _onDisconnected() {
    print(
      '[Upstox Feed] Disconnected',
    );

    _connected = false;

    _pingTimer?.cancel();

    _scheduleReconnect();
  }

  void _onError(
    Object error,
  ) {
    print(
      '[Upstox Feed] Error: $error',
    );

    _connected = false;

    _pingTimer?.cancel();

    _scheduleReconnect();
  }

  void _startHeartbeat() {
    _pingTimer?.cancel();

    _pingTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) {},
    );
  }

  void _scheduleReconnect() {
    if (_connecting) {
      return;
    }

    _reconnectAttempt++;

    final delay = Duration(
      seconds:
          _reconnectAttempt > 5
              ? 30
              : _reconnectAttempt * 3,
    );

    print(
      '[Upstox Feed] Reconnecting in '
      '${delay.inSeconds}s',
    );

    _reconnectTimer?.cancel();

    _reconnectTimer = Timer(
      delay,
      () async {
        await connect();
      },
    );
  }

  @override
  Future<void> subscribeFull(
    String instrumentKey,
  ) async {
    await subscribe([
      instrumentKey,
    ]);
  }

  @override
  Future<void> unsubscribeFull(
    String instrumentKey,
  ) async {
    await unsubscribe([
      instrumentKey,
    ]);
  }

  @override
  Future<void> subscribeMany(
    List<String> keys,
  ) async {
    if (keys.isEmpty) {
      return;
    }

    await subscribe(keys);
  }

  @override
  Future<void> unsubscribeMany(
    List<String> keys,
  ) async {
    if (keys.isEmpty) {
      return;
    }

    await unsubscribe(keys);
  }

  void clearSubscriptions() {
    _subscriptions.clear();
  }

  @override
  List<String> get subscriptions =>
      _subscriptions.toList();

  bool isSubscribed(
    String instrumentKey,
  ) {
    return _subscriptions.contains(
      instrumentKey,
    );
  }

  Future<void> resubscribeAll() async {
    if (!_connected ||
        _subscriptions.isEmpty) {
      return;
    }

    await subscribe(
      _subscriptions.toList(),
    );
  }

  @override
  StreamSubscription<FeedResponse> listen(
    void Function(FeedResponse data)
        onData,
  ) {
    return stream.listen(onData);
  }

  Future<void> reconnect() async {
    await disconnect();
    await connect();
  }

  Future<void> refreshSubscriptions() async {
    if (!_connected ||
        _subscriptions.isEmpty) {
      return;
    }

    await subscribe(
      _subscriptions.toList(),
    );
  }

  void dispose() {
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();

    _socket?.close();

    if (!_controller.isClosed) {
      _controller.close();
    }

    _connected = false;
    _connecting = false;

    _subscriptions.clear();
  }
}