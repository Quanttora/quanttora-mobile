﻿$ErrorActionPreference = "Stop"
Set-Location "D:\Quanttora\backend"

# Preserve current versions before applying the live-feed patch.
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
Copy-Item "lib\services\broker_startup_service.dart" "lib\services\broker_startup_service.dart.pre-zerodha-feed-$stamp"
Copy-Item "lib\routes\broker_routes.dart" "lib\routes\broker_routes.dart.pre-zerodha-feed-$stamp"

@'
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:backend/models/market_tick.dart';
import 'package:backend/services/market_store.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

/// Kite Connect live market feed. Kite uses numeric instrument tokens and
/// binary packets; this decoder is intentionally separate from Upstox protobuf.
class ZerodhaMarketFeed {
  ZerodhaMarketFeed._();
  static final ZerodhaMarketFeed instance = ZerodhaMarketFeed._();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  bool _connected = false;
  bool _connecting = false;
  String? _accessToken;
  String? _apiKey;
  String? _lastError;
  DateTime? _lastTickAt;

  final Set<int> _tokens = <int>{};
  final Map<int, String> _keysByToken = <int, String>{};
  final Map<String, int> _tokensByKey = <String, int>{};
  final Map<int, String> _symbolsByToken = <int, String>{};

  bool get isConnected => _connected;
  bool get isConnecting => _connecting;
  String? get lastError => _lastError;
  DateTime? get lastTickAt => _lastTickAt;
  List<String> get subscriptions =>
      _tokens.map((t) => _keysByToken[t] ?? '$t').toList(growable: false);

  String _readApiKey() {
    final fromEnvironment = Platform.environment['ZERODHA_API_KEY']?.trim();
    if (fromEnvironment != null && fromEnvironment.isNotEmpty) {
      return fromEnvironment;
    }
    final file = File('.env');
    if (!file.existsSync()) {
      throw StateError('ZERODHA_API_KEY is missing from environment and backend .env.');
    }
    for (final line in file.readAsLinesSync()) {
      final row = line.trim();
      if (row.startsWith('ZERODHA_API_KEY=')) {
        var value = row.substring('ZERODHA_API_KEY='.length).trim();
        if (value.length >= 2 &&
            ((value.startsWith('"') && value.endsWith('"')) ||
             (value.startsWith("'") && value.endsWith("'")))) {
          value = value.substring(1, value.length - 1);
        }
        if (value.isNotEmpty) return value;
      }
    }
    throw StateError('ZERODHA_API_KEY was not found in backend .env.');
  }

  Future<void> connect({required String accessToken}) async {
    if (_connected && _accessToken == accessToken) return;
    if (_connecting) return;
    _connecting = true;
    _lastError = null;
    try {
      await _closeSocket();
      _accessToken = accessToken;
      _apiKey = _readApiKey();

      final uri = Uri.https('api.kite.trade', '/instruments');
      final response = await http.get(uri, headers: {
        'X-Kite-Version': '3',
        'Authorization': 'token $_apiKey:$accessToken',
      }).timeout(const Duration(seconds: 20));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError('Kite instruments download failed (${response.statusCode}).');
      }
      _loadInstrumentMaster(response.body);

      final wsUri = Uri(scheme: 'wss', host: 'ws.kite.trade', path: '/', queryParameters: {
        'api_key': _apiKey!,
        'access_token': accessToken,
      });
      _channel = WebSocketChannel.connect(wsUri);
      await _channel!.ready.timeout(const Duration(seconds: 15));
      _connected = true;
      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: (Object error, StackTrace stack) {
          _lastError = error.toString();
          _connected = false;
          print('[Zerodha Feed] WebSocket error: $error');
        },
        onDone: () {
          _connected = false;
          print('[Zerodha Feed] WebSocket disconnected.');
        },
        cancelOnError: false,
      );

      // Subscribe to key indices by their instrument-master symbols, when present.
      await subscribeMany(const [
        'NSE:NIFTY 50',
        'NSE:NIFTY BANK',
        'BSE:SENSEX',
        'NSE:INDIA VIX',
      ]);
      print('[Zerodha Feed] Connected. Subscriptions: ${_tokens.length}.');
    } catch (error) {
      _lastError = error.toString();
      _connected = false;
      await _closeSocket();
      rethrow;
    } finally {
      _connecting = false;
    }
  }

  void _loadInstrumentMaster(String csv) {
    final lines = const LineSplitter().convert(csv);
    if (lines.length < 2) throw StateError('Kite instrument master is empty.');
    final headers = _parseCsvLine(lines.first);
    final tokenIndex = headers.indexOf('instrument_token');
    final exchangeIndex = headers.indexOf('exchange');
    final tradingsymbolIndex = headers.indexOf('tradingsymbol');
    if (tokenIndex < 0 || exchangeIndex < 0 || tradingsymbolIndex < 0) {
      throw StateError('Kite instrument master has unexpected columns.');
    }
    _tokensByKey.clear();
    _keysByToken.clear();
    _symbolsByToken.clear();
    for (final line in lines.skip(1)) {
      final fields = _parseCsvLine(line);
      if (fields.length <= [tokenIndex, exchangeIndex, tradingsymbolIndex].reduce((a,b) => a > b ? a : b)) continue;
      final token = int.tryParse(fields[tokenIndex]);
      final exchange = fields[exchangeIndex].trim();
      final symbol = fields[tradingsymbolIndex].trim();
      if (token == null || exchange.isEmpty || symbol.isEmpty) continue;
      final key = '$exchange:$symbol';
      _tokensByKey[key.toUpperCase()] = token;
      _keysByToken[token] = key;
      _symbolsByToken[token] = symbol;
    }
  }

  List<String> _parseCsvLine(String line) {
    final fields = <String>[];
    final buffer = StringBuffer();
    var quoted = false;
    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      if (c == '"') {
        if (quoted && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          quoted = !quoted;
        }
      } else if (c == ',' && !quoted) {
        fields.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(c);
      }
    }
    fields.add(buffer.toString());
    return fields;
  }

  Future<int> _resolveToken(String key) async {
    final trimmed = key.trim();
    final numeric = int.tryParse(trimmed);
    if (numeric != null && numeric > 0) {
      _keysByToken.putIfAbsent(numeric, () => trimmed);
      _symbolsByToken.putIfAbsent(numeric, () => trimmed);
      return numeric;
    }
    final token = _tokensByKey[trimmed.toUpperCase()];
    if (token != null) return token;
    throw ArgumentError(
      'Cannot map "$key" to a Kite instrument token. Use EXCHANGE:TRADINGSYMBOL (for example NSE:INFY) or a numeric instrument token.',
    );
  }

  Future<void> subscribeMany(List<String> instrumentKeys) async {
    if (!_connected || _channel == null) {
      throw StateError('Zerodha live feed is not connected.');
    }
    final resolved = <int>[];
    for (final key in instrumentKeys) {
      final token = await _resolveToken(key);
      _keysByToken[token] = key.trim();
      _tokens.add(token);
      resolved.add(token);
    }
    if (resolved.isNotEmpty) {
      _channel!.sink.add(jsonEncode({'a': 'subscribe', 'v': resolved}));
      _channel!.sink.add(jsonEncode({'a': 'mode', 'v': ['full', resolved]}));
    }
  }

  Future<void> unsubscribeMany(List<String> instrumentKeys) async {
    if (!_connected || _channel == null) {
      throw StateError('Zerodha live feed is not connected.');
    }
    final resolved = <int>[];
    for (final key in instrumentKeys) {
      final token = int.tryParse(key.trim()) ?? _tokensByKey[key.trim().toUpperCase()];
      if (token != null) {
        resolved.add(token);
        _tokens.remove(token);
      }
    }
    if (resolved.isNotEmpty) {
      _channel!.sink.add(jsonEncode({'a': 'unsubscribe', 'v': resolved}));
    }
  }

  void _onMessage(dynamic message) {
    try {
      if (message is String) {
        // Kite sends text messages for status/errors and binary messages for ticks.
        print('[Zerodha Feed] $message');
        return;
      }
      if (message is List<int>) {
        _decodePackets(Uint8List.fromList(message));
      }
    } catch (error) {
      _lastError = 'Tick decode error: $error';
      print('[Zerodha Feed] $_lastError');
    }
  }

  int _u16(Uint8List b, int o) => (b[o] << 8) | b[o + 1];
  int _u32(Uint8List b, int o) =>
      ((b[o] << 24) | (b[o + 1] << 16) | (b[o + 2] << 8) | b[o + 3]) & 0xffffffff;

  void _decodePackets(Uint8List bytes) {
    if (bytes.length < 2) return;
    final count = _u16(bytes, 0);
    var offset = 2;
    for (var i = 0; i < count; i++) {
      if (offset + 2 > bytes.length) return;
      final length = _u16(bytes, offset);
      offset += 2;
      if (length < 8 || offset + length > bytes.length) return;
      final packet = Uint8List.sublistView(bytes, offset, offset + length);
      _decodePacket(packet);
      offset += length;
    }
  }

  void _decodePacket(Uint8List p) {
    final token = _u32(p, 0) & 0x7fffffff;
    final price = _u32(p, 4) / 100.0;
    if (price <= 0) return;

    // LTP packets (8 bytes) and index quote packets (28 bytes) have no volume/depth.
    var previousClose = 0.0;
    var volume = 0;
    var averagePrice = 0.0;
    var bidPrice = 0.0;
    var askPrice = 0.0;
    var bidQty = 0;
    var askQty = 0;

    if (p.length >= 28) {
      // Index quote packet: token, LTP, high, low, open, close.
      previousClose = _u32(p, 24) / 100.0;
    }
    if (p.length >= 44) {
      // Tradable quote/full packets: volume and average traded price.
      averagePrice = _u32(p, 12) / 100.0;
      volume = _u32(p, 16);
      previousClose = _u32(p, 40) / 100.0;
    }
    if (p.length >= 184) {
      // Full packet depth begins at byte 64; each depth entry is 12 bytes.
      final depthOffset = 64;
      bidQty = _u32(p, depthOffset);
      bidPrice = _u32(p, depthOffset + 4) / 100.0;
      askQty = _u32(p, depthOffset + 60);
      askPrice = _u32(p, depthOffset + 64) / 100.0;
    }

    final key = _keysByToken[token] ?? '$token';
    final symbol = _symbolsByToken[token] ?? key;
    final change = previousClose > 0 ? price - previousClose : 0.0;
    final changePercent = previousClose > 0 ? change / previousClose * 100 : 0.0;
    final old = MarketStore.instance.get(key);
    final tick = MarketTick(
      instrumentKey: key,
      symbol: symbol,
      ltp: price,
      previousClose: previousClose > 0 ? previousClose : (old?.previousClose ?? 0),
      change: change,
      changePercent: changePercent,
      bidPrice: bidPrice,
      askPrice: askPrice,
      bidQuantity: bidQty,
      askQuantity: askQty,
      volume: volume,
      averageTradedPrice: averagePrice,
      vwap: old?.vwap ?? 0,
      timestamp: DateTime.now().toUtc(),
    );
    MarketStore.instance.update(tick);
    _lastTickAt = DateTime.now().toUtc();
  }

  Future<void> disconnect() async {
    _connected = false;
    _tokens.clear();
    await _closeSocket();
  }

  Future<void> _closeSocket() async {
    await _subscription?.cancel();
    _subscription = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _connected = false;
  }
}
'@ | Set-Content "lib\services\zerodha_market_feed.dart" -Encoding utf8

# Patch startup restoration to connect the Kite feed after restoring a valid session.
$startupPath = "lib\services\broker_startup_service.dart"
$startup = Get-Content $startupPath -Raw
if ($startup -notmatch "services/zerodha_market_feed.dart") {
  $startup = $startup.Replace(
    "import 'package:backend/services/upstox_market_feed.dart';",
    "import 'package:backend/services/upstox_market_feed.dart';`r`nimport 'package:backend/services/zerodha_market_feed.dart';"
  )
}
# Replace the actual Zerodha REST-only branch using the next Upstox branch as a boundary.
if ($startup -notmatch "services/zerodha_market_feed.dart") {
  $startup = $startup.Replace(
    "import 'package:backend/services/upstox_market_feed.dart';",
    "import 'package:backend/services/upstox_market_feed.dart';`r`nimport 'package:backend/services/zerodha_market_feed.dart';"
  )
}
if ($startup -notmatch "ZerodhaMarketFeed\.instance\.connect") {
  $pattern = '(?s)if\s*\(\s*_isZerodha\(broker\)\s*\)\s*\{.*?(?=\s*/\*.*?Only Upstox should start the Upstox market feed|\s*if\s*\(\s*_isUpstox\(broker\)\s*\))'
  $replacement = @'
    if (_isZerodha(broker)) {
      try {
        await ZerodhaMarketFeed.instance.connect(accessToken: accessToken);
        print('[Broker Startup] Zerodha live WebSocket connected.');
      } catch (error) {
        print('[Broker Startup] Zerodha live WebSocket could not connect: $error');
      }
      return;
    }

'@
  $updated = [regex]::Replace($startup, $pattern, $replacement, 1)
  if ($updated -eq $startup) {
    throw "Could not locate Zerodha startup branch before Upstox branch. No further files changed."
  }
  $startup = $updated
}
Set-Content $startupPath $startup -Encoding utf8

# Patch broker routes: report actual stream state and route feed actions to Kite.
$routesPath = "lib\routes\broker_routes.dart"
$routes = Get-Content $routesPath -Raw
if ($routes -notmatch "services/zerodha_market_feed.dart") {
  $routes = $routes.Replace(
    "import 'package:backend/services/upstox_market_feed.dart';",
    "import 'package:backend/services/upstox_market_feed.dart';`r`nimport 'package:backend/services/zerodha_market_feed.dart';"
  )
}
$routes = $routes.Replace(
@'
  bool _marketFeedConnected(Request request) {
    if (_isZerodha(request)) {
      return _brokerService.hasValidSessionForUser(_userId(request));
    }
    return UpstoxMarketFeed.instance.isConnected;
  }
'@,
@'
  bool _marketFeedConnected(Request request) {
    if (_isZerodha(request)) {
      return ZerodhaMarketFeed.instance.isConnected;
    }
    return UpstoxMarketFeed.instance.isConnected;
  }
'@
)
$routes = $routes.Replace(
@'
      if (_isZerodha(request)) {
        return _json({
          'success': true,
          'connected': true,
          'broker': 'Zerodha',
          'mode': 'REST_QUOTES',
        });
      }
'@,
@'
      if (_isZerodha(request)) {
        await ZerodhaMarketFeed.instance.connect(
          accessToken: _brokerService.accessTokenForUser(userId),
        );
        return _json({
          'success': true,
          'connected': ZerodhaMarketFeed.instance.isConnected,
          'broker': 'Zerodha',
          'mode': 'KITE_WEBSOCKET',
          'subscriptions': ZerodhaMarketFeed.instance.subscriptions,
        });
      }
'@
)
$routes = $routes.Replace(
@'
      if (_isZerodha(request)) {
        return _json({
          'success': true,
          'connected': false,
          'broker': 'Zerodha',
        });
      }
'@,
@'
      if (_isZerodha(request)) {
        await ZerodhaMarketFeed.instance.disconnect();
        return _json({
          'success': true,
          'connected': ZerodhaMarketFeed.instance.isConnected,
          'broker': 'Zerodha',
        });
      }
'@
)
$routes = $routes.Replace(
@'
  Future<Response> _subscribeMarketFeed(Request request) async {
    _userId(request);
'@,
@'
  Future<Response> _subscribeMarketFeed(Request request) async {
    final userId = _userId(request);
'@
)
$routes = $routes.Replace(
@'
    try {
      await UpstoxMarketFeed.instance.subscribeFull(instrumentKey.trim());

      return _json({
'@,
@'
    try {
      if (_isZerodha(request)) {
        await ZerodhaMarketFeed.instance.subscribeMany([instrumentKey.trim()]);
        return _json({
          'success': true,
          'instrument': instrumentKey.trim(),
          'connected': ZerodhaMarketFeed.instance.isConnected,
          'subscriptions': ZerodhaMarketFeed.instance.subscriptions,
        });
      }
      await UpstoxMarketFeed.instance.subscribeFull(instrumentKey.trim());

      return _json({
'@
)
$routes = $routes.Replace(
@'
  Future<Response> _unsubscribeMarketFeed(Request request) async {
    _userId(request);
'@,
@'
  Future<Response> _unsubscribeMarketFeed(Request request) async {
    final userId = _userId(request);
'@
)
$routes = $routes.Replace(
@'
    try {
      await UpstoxMarketFeed.instance.unsubscribeFull(instrumentKey.trim());

      return _json({
'@,
@'
    try {
      if (_isZerodha(request)) {
        await ZerodhaMarketFeed.instance.unsubscribeMany([instrumentKey.trim()]);
        return _json({
          'success': true,
          'connected': ZerodhaMarketFeed.instance.isConnected,
          'subscriptions': ZerodhaMarketFeed.instance.subscriptions,
        });
      }
      await UpstoxMarketFeed.instance.unsubscribeFull(instrumentKey.trim());

      return _json({
'@
)
$routes = $routes.Replace(
@'
    return _json({
      'success': true,
      'connected': UpstoxMarketFeed.instance.isConnected,
      'subscriptions': _isZerodha(request)
          ? const <String>[]
          : UpstoxMarketFeed.instance.subscriptions,
    });
'@,
@'
    return _json({
      'success': true,
      'connected': _isZerodha(request)
          ? ZerodhaMarketFeed.instance.isConnected
          : UpstoxMarketFeed.instance.isConnected,
      'lastTickAt': _isZerodha(request)
          ? ZerodhaMarketFeed.instance.lastTickAt?.toIso8601String()
          : null,
      'lastError': _isZerodha(request) ? ZerodhaMarketFeed.instance.lastError : null,
      'subscriptions': _isZerodha(request)
          ? ZerodhaMarketFeed.instance.subscriptions
          : UpstoxMarketFeed.instance.subscriptions,
    });
'@
)
Set-Content $routesPath $routes -Encoding utf8

Write-Host ""
Write-Host "Zerodha live-feed files and route/startup patches written."
Write-Host "Running one Dart analysis check..."
dart analyze lib\services\zerodha_market_feed.dart lib\services\broker_startup_service.dart lib\routes\broker_routes.dart
