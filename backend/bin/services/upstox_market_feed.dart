import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:backend/models/broker_session.dart';
import 'package:backend/services/broker_service.dart';
import 'package:backend/generated/market_data_v3.pb.dart';
import 'package:http/http.dart' as http;

class UpstoxMarketFeed {
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

  Stream<FeedResponse> get stream => _controller.stream;

  bool get isConnected => _connected;

  Future<void> connect() async {
    if (_connecting || _connected) {
      return;
    }

    _connecting = true;

    try {
      final session = BrokerService.instance.session;

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

      print(
        '[Upstox Feed] Connected',
      );
    } catch (e) {
      _connecting = false;
      _connected = false;

      print(
        '[Upstox Feed] Connection failed: $e',
      );

      _scheduleReconnect();
    }
  }

  Future<void> disconnect() async {
    _connected = false;

    _pingTimer?.cancel();
    _reconnectTimer?.cancel();

    await _socket?.close();

    _socket = null;
  }

  Future<void> subscribe(
    List<String> instruments,
  ) async {
    _subscriptions.addAll(
      instruments,
    );

    if (!_connected) {
      return;
    }

    final payload = {
      "guid": DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      "method": "sub",
      "data": {
        "mode": "full",
        "instrumentKeys": instruments,
      }
    };

    _socket?.add(
      jsonEncode(payload),
    );
  }

  Future<void> unsubscribe(
    List<String> instruments,
  ) async {
    _subscriptions.removeAll(
      instruments,
    );

    if (!_connected) {
      return;
    }

    final payload = {
      "guid": DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      "method": "unsub",
      "data": {
        "instrumentKeys": instruments,
      }
    };

    _socket?.add(
      jsonEncode(payload),
    );
  }

  Future<String> _getAuthorizedWebSocketUrl(
    BrokerSession session,
  ) async {
    final response =
        await http.get(
      Uri.parse(_authorizeUrl),
      headers: {
        'Authorization':
            'Bearer ${session.accessToken}',
        'Accept':
            'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body,
      );
    }

    final json =
        jsonDecode(response.body);

    return json['data']
        ['authorizedRedirectUri'];
  }
  Future<void> _connectSocket(
    String url,
  ) async {
    _socket =
        await WebSocket.connect(url);

    _socket!.pingInterval =
        const Duration(
      seconds: 20,
    );

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
    try {
      if (message is List<int>) {
        final response =
            FeedResponse.fromBuffer(
          message,
        );

        _controller.add(
          response,
        );
      }
    } catch (e) {
      print(
        '[Upstox Feed] Decode Error: $e',
      );
    }
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
      const Duration(
        seconds: 20,
      ),
      (_) {
        try {
          _socket?.pingInterval =
              const Duration(
            seconds: 20,
          );
        } catch (_) {}
      },
    );
  }

  void _scheduleReconnect() {
    if (_connecting) {
      return;
    }

    _reconnectAttempt++;

    final delay =
        Duration(
      seconds:
          _reconnectAttempt > 5
              ? 30
              : _reconnectAttempt * 3,
    );

    print(
      '[Upstox Feed] Reconnecting in ${delay.inSeconds}s',
    );

    _reconnectTimer?.cancel();

    _reconnectTimer = Timer(
      delay,
      () async {
        await connect();
      },
    );
  }
  Future<void> subscribeFull(
    String instrumentKey,
  ) async {
    await subscribe([
      instrumentKey,
    ]);
  }

  Future<void> unsubscribeFull(
    String instrumentKey,
  ) async {
    await unsubscribe([
      instrumentKey,
    ]);
  }

  Future<void> subscribeMany(
    List<String> keys,
  ) async {
    if (keys.isEmpty) return;

    await subscribe(keys);
  }

  Future<void> unsubscribeMany(
    List<String> keys,
  ) async {
    if (keys.isEmpty) return;

    await unsubscribe(keys);
  }

  void clearSubscriptions() {
    _subscriptions.clear();
  }

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
    if (!_connected) {
      return;
    }

    if (_subscriptions.isEmpty) {
      return;
    }

    final payload = {
      "guid":
          DateTime.now()
              .millisecondsSinceEpoch
              .toString(),
      "method": "sub",
      "data": {
        "mode": "full",
        "instrumentKeys":
            _subscriptions.toList(),
      }
    };

    _socket?.add(
      jsonEncode(payload),
    );

    print(
      '[Upstox Feed] Resubscribed ${_subscriptions.length} instruments',
    );
  }

  StreamSubscription<FeedResponse>
      listen(
    void Function(
      FeedResponse data,
    )
        onData,
  ) {
    return stream.listen(
      onData,
    );
  }
  Future<void> reconnect() async {
    await disconnect();
    await connect();
  }

  Future<void> refreshSubscriptions() async {
    if (!_connected) {
      return;
    }

    if (_subscriptions.isEmpty) {
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