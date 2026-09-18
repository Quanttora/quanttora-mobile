import 'package:backend/models/market_candle.dart';
import 'package:backend/services/broker_market_service.dart';
import 'package:backend/services/broker_service.dart';
import 'package:backend/services/vwap_service.dart';

class MarketCandleService {
  MarketCandleService._();

  static final MarketCandleService instance = MarketCandleService._();

  final BrokerService _brokerService = BrokerService.instance;

  final BrokerMarketService _brokerMarketService =
      BrokerMarketService.instance;

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

    final normalizedFromDate = fromDate.trim();
    final normalizedToDate = toDate.trim();

    final from = _parseDateOnly(normalizedFromDate);
    final to = _parseDateOnly(normalizedToDate);

    if (from == null || to == null) {
      throw ArgumentError(
        'Invalid candle date range. Dates must use YYYY-MM-DD.',
      );
    }

    if (from.isAfter(to)) {
      throw ArgumentError(
        'Candle fromDate cannot be after toDate.',
      );
    }

    final todayDate = _dateOnly(DateTime.now());

    final candlesByTimestamp = <String, MarketCandle>{};

    /*
     * Upstox historical-candle does not accept a date range that
     * includes the current trading day.
     *
     * Therefore:
     *
     *   requested range ending before today
     *       -> historical endpoint only
     *
     *   requested range including today
     *       -> historical endpoint through yesterday
     *       -> intraday endpoint for today
     */

    final includesToday =
        !to.isBefore(todayDate) && !from.isAfter(todayDate);

    final historicalToDate =
        includesToday ? todayDate.subtract(const Duration(days: 1)) : to;

    final hasHistoricalRange =
        !from.isAfter(historicalToDate);

    if (hasHistoricalRange) {
      final historicalResponse =
          await _brokerMarketService.current.getHistoricalCandles(
        session.accessToken,
        instrumentKey,
        interval,
        _formatDate(historicalToDate),
        _formatDate(from),
      );

      _addRawCandles(
        candlesByTimestamp,
        instrumentKey,
        historicalResponse,
      );
    }

    /*
     * Current trading day.
     *
     * The intraday endpoint returns the current day's candles.
     * We only add them when today's date is inside the requested range.
     */
    if (includesToday) {
      final intradayResponse =
          await _brokerMarketService.current.getIntradayCandles(
        session.accessToken,
        instrumentKey,
        interval,
      );

      _addRawCandles(
        candlesByTimestamp,
        instrumentKey,
        intradayResponse,
      );
    }

    final candles = candlesByTimestamp.values.toList()
      ..sort(
        (a, b) => a.timestamp.compareTo(b.timestamp),
      );

    /*
     * Keep the final result strictly inside the requested date range.
     *
     * This also protects us from any extra current-day candles returned
     * by the intraday endpoint when the requested range ends before today.
     */
    final filtered = candles.where((candle) {
      final localDate = DateTime(
        candle.timestamp.toLocal().year,
        candle.timestamp.toLocal().month,
        candle.timestamp.toLocal().day,
      );

      return !localDate.isBefore(from) &&
          !localDate.isAfter(to);
    }).toList();

    return filtered;
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

    return _vwapService.calculateFromCandles(
      instrumentKey,
      candles,
    );
  }

  double currentVwap(String instrumentKey) {
    return _vwapService.currentVwap(instrumentKey);
  }

  static void _addRawCandles(
    Map<String, MarketCandle> target,
    String instrumentKey,
    Map<String, dynamic> response,
  ) {
    final data = response['data'];

    if (data is! Map) {
      return;
    }

    final rawCandles = data['candles'];

    if (rawCandles is! List) {
      return;
    }

    for (final raw in rawCandles) {
      if (raw is! List || raw.length < 6) {
        continue;
      }

      final timestamp = DateTime.tryParse(
        raw[0].toString(),
      );

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

      final candle = MarketCandle(
        instrumentKey: instrumentKey,
        timestamp: timestamp,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      );

      /*
       * Timestamp is the unique candle identity.
       *
       * Historical and intraday responses can overlap at boundaries,
       * so the map automatically removes duplicates.
       */
      final key = timestamp.toUtc().toIso8601String();

      target[key] = candle;
    }
  }

  static DateTime? _parseDateOnly(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return null;
    }

    final parsed = DateTime.tryParse(trimmed);

    if (parsed == null) {
      return null;
    }

    return DateTime(
      parsed.year,
      parsed.month,
      parsed.day,
    );
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(
      value.year,
      value.month,
      value.day,
    );
  }

  static String _formatDate(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  static double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }
}