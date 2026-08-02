import 'package:flutter/foundation.dart';

import '../market_data/models/candle.dart';
import '../market_data/models/heat_map.dart';
import '../market_data/models/market_snapshot.dart';
import '../market_data/models/oi_data.dart';
import '../market_data/models/option_chain.dart';
import '../market_data/models/sector_strength.dart';
import '../network/api_client.dart';

class MarketDataService {
  final ApiClient _api = ApiClient.instance;

  static const Map<String, String> _instrumentKeys = {
    'NIFTY': 'NSE_INDEX|Nifty 50',
    'NIFTY 50': 'NSE_INDEX|Nifty 50',
    'BANKNIFTY': 'NSE_INDEX|Nifty Bank',
    'BANK NIFTY': 'NSE_INDEX|Nifty Bank',
    'SENSEX': 'BSE_INDEX|SENSEX',
    'INDIA VIX': 'NSE_INDEX|India VIX',
  };

  Future<MarketSnapshot> fetchSnapshot({
    required String market,
    String timeframe = '3 min',
  }) async {
    final dashboard = await _api.get(
      '/market/dashboard',
    );

    final candles = await _fetchHistoricalCandles(
      market: market,
      timeframe: timeframe,
    );

    final indices =
        dashboard['indices'] as Map<String, dynamic>? ??
            <String, dynamic>{};

    final marketKey = _dashboardKey(market);

    final marketData =
        indices[marketKey] as Map<String, dynamic>?;

    final livePrice = _toDouble(
      marketData?['ltp'],
    );

    final finalCandles =
        List<Candle>.from(candles);

    if (livePrice > 0 && finalCandles.isEmpty) {
      finalCandles.add(
        Candle(
          open: livePrice,
          high: livePrice,
          low: livePrice,
          close: livePrice,
          volume: 0,
          time: DateTime.now(),
        ),
      );
    }

    return MarketSnapshot(
      candles: finalCandles.isNotEmpty
          ? finalCandles
          : emptySnapshot().candles,
      optionChain: const OptionChain(
        pcr: 1.08,
        maxCallOI: 25200,
        maxPutOI: 25000,
        callVolume: 215000,
        putVolume: 198000,
      ),
      oiData: const OIData(
        callOIChange: 12000,
        putOIChange: 18000,
        callWriting: 8500,
        putWriting: 14500,
      ),
      heatMap: HeatMap(
        advancing:
            dashboard['marketOpen'] == true
                ? 34
                : 0,
        declining:
            dashboard['marketOpen'] == true
                ? 16
                : 0,
        strongestSector: 'Banking',
        weakestSector: 'FMCG',
      ),
      sectorStrength: const SectorStrength(
        name: 'Banking',
        strength: 92,
        leading: true,
      ),
    );
  }

  Future<List<Candle>> _fetchHistoricalCandles({
    required String market,
    required String timeframe,
  }) async {
    final instrumentKey =
        _instrumentKeys[market.toUpperCase()];

    if (instrumentKey == null) {
      debugPrint(
        '[Quanttora] Unsupported market: $market',
      );

      return <Candle>[];
    }

    /*
      Upstox historical API currently accepts
      1minute but not 3minute / 5minute / 15minute.

      Quanttora therefore fetches 1-minute candles
      and builds the requested intraday timeframe
      locally.
    */

    final apiInterval =
        _apiIntervalFor(timeframe);

    final now = DateTime.now();

    final from = now.subtract(
      const Duration(days: 10),
    );

    final fromDate = _formatDate(from);
    final toDate = _formatDate(now);

    final encodedInstrument =
        Uri.encodeQueryComponent(
      instrumentKey,
    );

    final path =
        '/broker/history'
        '?instrumentKey=$encodedInstrument'
        '&interval=$apiInterval'
        '&fromDate=$fromDate'
        '&toDate=$toDate';

    try {
      final response =
          await _api.get(path);

      final data =
          response['data']
              as Map<String, dynamic>?;

      final rawCandles =
          data?['candles']
              as List<dynamic>?;

      if (rawCandles == null ||
          rawCandles.isEmpty) {
        debugPrint(
          '[Quanttora] Historical API returned 0 candles.',
        );

        return <Candle>[];
      }

      debugPrint(
        '[Quanttora] Real 1-minute candles received: ${rawCandles.length}',
      );

      final candles = <Candle>[];

      for (final raw in rawCandles) {
        if (raw is! List ||
            raw.length < 6) {
          continue;
        }

        final time =
            DateTime.tryParse(
          raw[0].toString(),
        );

        if (time == null) {
          continue;
        }

        candles.add(
          Candle(
            open: _toDouble(raw[1]),
            high: _toDouble(raw[2]),
            low: _toDouble(raw[3]),
            close: _toDouble(raw[4]),
            volume: _toDouble(raw[5]),
            time: time,
          ),
        );
      }

      candles.sort(
        (a, b) =>
            a.time.compareTo(b.time),
      );

      final minutes =
          _timeframeMinutes(timeframe);

      if (minutes <= 1) {
        debugPrint(
          '[Quanttora] Final candles: ${candles.length}',
        );

        return candles;
      }

      final aggregated =
          _aggregateCandles(
        candles,
        minutes,
      );

      debugPrint(
        '[Quanttora] ${timeframe.trim()} candles generated: ${aggregated.length}',
      );

      return aggregated;
    } catch (e) {
      debugPrint(
        '[Quanttora] Historical candle error: $e',
      );

      return <Candle>[];
    }
  }

  List<Candle> _aggregateCandles(
    List<Candle> source,
    int minutes,
  ) {
    if (source.isEmpty ||
        minutes <= 1) {
      return source;
    }

    final result = <Candle>[];

    final groups =
        <DateTime, List<Candle>>{};

    for (final candle in source) {
      final time = candle.time;

      final bucketMinute =
          (time.minute ~/ minutes) *
              minutes;

      final bucket = DateTime(
        time.year,
        time.month,
        time.day,
        time.hour,
        bucketMinute,
      );

      groups.putIfAbsent(
        bucket,
        () => <Candle>[],
      );

      groups[bucket]!.add(candle);
    }

    final keys =
        groups.keys.toList()
          ..sort();

    for (final key in keys) {
      final group = groups[key]!;

      group.sort(
        (a, b) =>
            a.time.compareTo(b.time),
      );

      if (group.isEmpty) {
        continue;
      }

      double high =
          group.first.high;

      double low =
          group.first.low;

      double volume = 0;

      for (final candle in group) {
        if (candle.high > high) {
          high = candle.high;
        }

        if (candle.low < low) {
          low = candle.low;
        }

        volume += candle.volume;
      }

      result.add(
        Candle(
          open: group.first.open,
          high: high,
          low: low,
          close: group.last.close,
          volume: volume,
          time: key,
        ),
      );
    }

    return result;
  }

  String _apiIntervalFor(
    String timeframe,
  ) {
    switch (
        timeframe.trim().toLowerCase()) {
      case '30 min':
        return '30minute';

      case '1 day':
        return 'day';

      default:
        return '1minute';
    }
  }

  int _timeframeMinutes(
    String timeframe,
  ) {
    switch (
        timeframe.trim().toLowerCase()) {
      case '1 min':
        return 1;

      case '3 min':
        return 3;

      case '5 min':
        return 5;

      case '15 min':
        return 15;

      case '30 min':
        return 30;

      case '1 hour':
        return 60;

      default:
        return 1;
    }
  }

  String _dashboardKey(
    String market,
  ) {
    switch (market.toUpperCase()) {
      case 'BANKNIFTY':
      case 'BANK NIFTY':
        return 'bankNifty';

      case 'SENSEX':
        return 'sensex';

      case 'INDIA VIX':
        return 'indiaVix';

      case 'NIFTY':
      case 'NIFTY 50':
      default:
        return 'nifty';
    }
  }

  String _formatDate(
    DateTime date,
  ) {
    final year =
        date.year.toString();

    final month =
        date.month
            .toString()
            .padLeft(2, '0');

    final day =
        date.day
            .toString()
            .padLeft(2, '0');

    return '$year-$month-$day';
  }

  double _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return 0;
    }

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  MarketSnapshot emptySnapshot() {
    return MarketSnapshot(
      candles: [
        Candle(
          open: 0,
          high: 0,
          low: 0,
          close: 0,
          volume: 0,
          time: DateTime.now(),
        ),
      ],
      optionChain:
          const OptionChain(
        pcr: 0,
        maxCallOI: 0,
        maxPutOI: 0,
        callVolume: 0,
        putVolume: 0,
      ),
      oiData: const OIData(
        callOIChange: 0,
        putOIChange: 0,
        callWriting: 0,
        putWriting: 0,
      ),
      heatMap: const HeatMap(
        advancing: 0,
        declining: 0,
        strongestSector: '-',
        weakestSector: '-',
      ),
      sectorStrength:
          const SectorStrength(
        name: '-',
        strength: 0,
        leading: false,
      ),
    );
  }
}