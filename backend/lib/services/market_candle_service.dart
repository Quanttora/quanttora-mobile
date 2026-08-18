import 'package:backend/models/market_candle.dart';
import 'package:backend/services/broker_market_service.dart';
import 'package:backend/services/broker_service.dart';
import 'package:backend/services/vwap_service.dart';

class MarketCandleService {
  MarketCandleService._();

  static final MarketCandleService instance = MarketCandleService._();

  final BrokerService _brokerService = BrokerService.instance;

  final BrokerMarketService _brokerMarketService = BrokerMarketService.instance;

  final VwapService _vwapService = VwapService.instance;

  Future<List<MarketCandle>> getHistoricalCandles({
    required String instrumentKey,
    required String interval,
    required String toDate,
    required String fromDate,
  }) async {
    final session = _brokerService.session;

    if (session == null) {
      throw StateError('No broker connected.');
    }

    final response = await _brokerMarketService.current.getHistoricalCandles(
      session.accessToken,
      instrumentKey,
      interval,
      toDate,
      fromDate,
    );

    final data = response['data'];

    if (data is! Map) {
      return [];
    }

    final rawCandles = data['candles'];

    if (rawCandles is! List) {
      return [];
    }

    final candles = <MarketCandle>[];

    for (final raw in rawCandles) {
      if (raw is! List || raw.length < 6) {
        continue;
      }

      final timestamp = DateTime.tryParse(raw[0].toString());

      if (timestamp == null) {
        continue;
      }

      final open = _toDouble(raw[1]);
      final high = _toDouble(raw[2]);
      final low = _toDouble(raw[3]);
      final close = _toDouble(raw[4]);
      final volume = _toInt(raw[5]);

      if (open == null ||
          high == null ||
          low == null ||
          close == null ||
          volume == null) {
        continue;
      }

      candles.add(
        MarketCandle(
          instrumentKey: instrumentKey,
          timestamp: timestamp,
          open: open,
          high: high,
          low: low,
          close: close,
          volume: volume,
        ),
      );
    }

    candles.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return candles;
  }

  Future<double> calculateHistoricalVwap({
    required String instrumentKey,
    required String interval,
    required String toDate,
    required String fromDate,
  }) async {
    final candles = await getHistoricalCandles(
      instrumentKey: instrumentKey,
      interval: interval,
      toDate: toDate,
      fromDate: fromDate,
    );

    return _vwapService.calculateFromCandles(instrumentKey, candles);
  }

  double currentVwap(String instrumentKey) {
    return _vwapService.currentVwap(instrumentKey);
  }

  static double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }

  static int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '');
  }
}
