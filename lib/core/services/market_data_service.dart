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

  Future<Map<String, dynamic>> fetchMarketDashboard() async {
    return _api.get('/market/dashboard');
  }

  Future<MarketSnapshot> fetchSnapshot({
    required String market,
    String timeframe = '3 min',
  }) async {
    debugPrint('===== FETCH SNAPSHOT CALLED =====');

    final dashboard = await _api.get('/market/dashboard');

    final candles = await _fetchHistoricalCandles(
      market: market,
      timeframe: timeframe,
    );

    final optionData = await _fetchOptionChain(market: market);

    final indices =
        dashboard['indices'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final marketKey = _dashboardKey(market);

    final marketData = indices[marketKey] as Map<String, dynamic>?;

    final livePrice = _toDouble(marketData?['ltp']);

    final bidPrice = _toDouble(marketData?['bidPrice']);
    final askPrice = _toDouble(marketData?['askPrice']);

    final bidQuantity =
    (marketData?['bidQuantity'] as num?)?.toInt() ?? 0;

    final askQuantity =
    (marketData?['askQuantity'] as num?)?.toInt() ?? 0;

    final finalCandles = List<Candle>.from(candles);

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
  candles: finalCandles.isNotEmpty ? finalCandles : emptySnapshot().candles,

  // REAL UPSTOX OPTION CHAIN
  optionChain: optionData.optionChain,

  // REAL UPSTOX OI DATA
  oiData: optionData.oiData,

  // REAL SECTOR BREADTH
  heatMap: _buildRealHeatMap(dashboard),

  // REAL SECTOR STRENGTH
  sectorStrength: _buildRealSectorStrength(dashboard),

  bidPrice: bidPrice,
  askPrice: askPrice,
  bidQuantity: bidQuantity,
  askQuantity: askQuantity,
);
  }

  Future<_OptionAnalytics> _fetchOptionChain({required String market}) async {
    final instrumentKey = _instrumentKeys[market.toUpperCase()];

    if (instrumentKey == null) {
      return _OptionAnalytics.empty();
    }

    if (market.toUpperCase() == 'INDIA VIX') {
      return _OptionAnalytics.empty();
    }

    final encodedInstrument = Uri.encodeQueryComponent(instrumentKey);

    final path =
        '/broker/option-chain'
        '?instrumentKey=$encodedInstrument'
        '&expiry=current_week';

    try {
      final response = await _api.get(path);

      final rawData = response['data'] as List<dynamic>?;

      if (rawData == null || rawData.isEmpty) {
        debugPrint('[Quanttora] Option Chain returned 0 rows.');

        return _OptionAnalytics.empty();
      }

      double totalCallOI = 0;
      double totalPutOI = 0;

      double totalCallVolume = 0;
      double totalPutVolume = 0;

      double totalCallOIChange = 0;
      double totalPutOIChange = 0;

      double callWriting = 0;
      double putWriting = 0;

      double maxCallOI = 0;
      double maxPutOI = 0;

      double maxCallOIStrike = 0;
      double maxPutOIStrike = 0;

      for (final row in rawData) {
        if (row is! Map) {
          continue;
        }

        final strikePrice = _toDouble(row['strike_price']);

        final callOptions = row['call_options'];

        final putOptions = row['put_options'];

        Map<dynamic, dynamic>? callMarket;

        Map<dynamic, dynamic>? putMarket;

        if (callOptions is Map) {
          final value = callOptions['market_data'];

          if (value is Map) {
            callMarket = value;
          }
        }

        if (putOptions is Map) {
          final value = putOptions['market_data'];

          if (value is Map) {
            putMarket = value;
          }
        }

        final callOI = _toDouble(callMarket?['oi']);

        final putOI = _toDouble(putMarket?['oi']);

        final callPrevOI = _toDouble(callMarket?['prev_oi']);

        final putPrevOI = _toDouble(putMarket?['prev_oi']);

        final callVolume = _toDouble(callMarket?['volume']);

        final putVolume = _toDouble(putMarket?['volume']);

        final callChange = callOI - callPrevOI;

        final putChange = putOI - putPrevOI;

        totalCallOI += callOI;
        totalPutOI += putOI;

        totalCallVolume += callVolume;
        totalPutVolume += putVolume;

        totalCallOIChange += callChange;

        totalPutOIChange += putChange;

        if (callChange > 0) {
          callWriting += callChange;
        }

        if (putChange > 0) {
          putWriting += putChange;
        }

        if (callOI > maxCallOI) {
          maxCallOI = callOI;
          maxCallOIStrike = strikePrice;
        }

        if (putOI > maxPutOI) {
          maxPutOI = putOI;
          maxPutOIStrike = strikePrice;
        }
      }

      final pcr = totalCallOI > 0 ? totalPutOI / totalCallOI : 0.0;

      debugPrint('[Quanttora] REAL OPTION CHAIN');

      debugPrint('[Quanttora] Rows: ${rawData.length}');

      debugPrint('[Quanttora] PCR: ${pcr.toStringAsFixed(2)}');

      debugPrint('[Quanttora] Max Call OI Strike: $maxCallOIStrike');

      debugPrint('[Quanttora] Max Put OI Strike: $maxPutOIStrike');

      return _OptionAnalytics(
        optionChain: OptionChain(
          pcr: pcr,
          maxCallOI: maxCallOIStrike,
          maxPutOI: maxPutOIStrike,
          callVolume: totalCallVolume,
          putVolume: totalPutVolume,
        ),
        oiData: OIData(
          callOIChange: totalCallOIChange,
          putOIChange: totalPutOIChange,
          callWriting: callWriting,
          putWriting: putWriting,
        ),
      );
    } catch (e) {
      debugPrint('[Quanttora] Option Chain error: $e');

      return _OptionAnalytics.empty();
    }
  }

  HeatMap _buildRealHeatMap(Map<String, dynamic> dashboard) {
    final rawSectors = dashboard['sectors'] as List<dynamic>?;

    if (rawSectors == null || rawSectors.isEmpty) {
      return const HeatMap(
        advancing: 0,
        declining: 0,
        strongestSector: '-',
        weakestSector: '-',
      );
    }

    int advancing = 0;
    int declining = 0;

    String strongestSector = '-';
    String weakestSector = '-';

    double? strongestChange;
    double? weakestChange;

    for (final raw in rawSectors) {
      if (raw is! Map) {
        continue;
      }

      final name = raw['name']?.toString() ?? '-';

      final change = _toDouble(raw['percentageChange']);

      if (change > 0) {
        advancing++;
      } else if (change < 0) {
        declining++;
      }

      if (strongestChange == null || change > strongestChange) {
        strongestChange = change;

        strongestSector = name;
      }

      if (weakestChange == null || change < weakestChange) {
        weakestChange = change;

        weakestSector = name;
      }
    }

    debugPrint(
      '[Quanttora] REAL SECTOR BREADTH '
      'Advancing: $advancing '
      'Declining: $declining',
    );

    debugPrint(
      '[Quanttora] Strongest Sector: '
      '$strongestSector',
    );

    debugPrint(
      '[Quanttora] Weakest Sector: '
      '$weakestSector',
    );

    return HeatMap(
      advancing: advancing,
      declining: declining,
      strongestSector: strongestSector,
      weakestSector: weakestSector,
    );
  }

  SectorStrength _buildRealSectorStrength(Map<String, dynamic> dashboard) {
    final rawSectors = dashboard['sectors'] as List<dynamic>?;

    if (rawSectors == null || rawSectors.isEmpty) {
      return const SectorStrength(name: '-', strength: 0, leading: false);
    }

    Map<dynamic, dynamic>? strongest;

    for (final raw in rawSectors) {
      if (raw is! Map) {
        continue;
      }

      if (strongest == null) {
        strongest = raw;
        continue;
      }

      final currentChange = _toDouble(raw['percentageChange']);

      final strongestChange = _toDouble(strongest['percentageChange']);

      if (currentChange > strongestChange) {
        strongest = raw;
      }
    }

    if (strongest == null) {
      return const SectorStrength(name: '-', strength: 0, leading: false);
    }

    final name = strongest['name']?.toString() ?? '-';

    final percentageChange = _toDouble(strongest['percentageChange']);

    debugPrint(
      '[Quanttora] REAL LEADING SECTOR '
      '$name '
      '${percentageChange.toStringAsFixed(2)}%',
    );

    return SectorStrength(
      name: name,
      strength: percentageChange,
      leading: percentageChange > 0,
    );
  }

  Future<List<Candle>> _fetchHistoricalCandles({
    required String market,
    required String timeframe,
  }) async {
    debugPrint('===== FETCH HISTORICAL CALLED =====');

    final instrumentKey = _instrumentKeys[market.toUpperCase()];

    if (instrumentKey == null) {
      debugPrint('[Quanttora] Unsupported market: $market');

      return <Candle>[];
    }

    final apiInterval = _apiIntervalFor(timeframe);

    final now = DateTime.now();

    final from = now.subtract(const Duration(days: 10));

    final fromDate = _formatDate(from);

    final toDate = _formatDate(now);

    final encodedInstrument = Uri.encodeQueryComponent(instrumentKey);

    final path =
        '/broker/history'
        '?instrumentKey=$encodedInstrument'
        '&interval=$apiInterval'
        '&fromDate=$fromDate'
        '&toDate=$toDate';

    try {
      final response = await _api.get(path);

      final data = response['data'] as Map<String, dynamic>?;

      final rawCandles = data?['candles'] as List<dynamic>?;

      if (rawCandles == null || rawCandles.isEmpty) {
        debugPrint('[Quanttora] Historical API returned 0 candles.');

        return <Candle>[];
      }

      debugPrint(
        '[Quanttora] Real 1-minute candles received: ${rawCandles.length}',
      );

      final candles = <Candle>[];

      for (final raw in rawCandles) {
        if (raw is! List || raw.length < 6) {
          continue;
        }

        final time = DateTime.tryParse(raw[0].toString());

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

      candles.sort((a, b) => a.time.compareTo(b.time));

      final minutes = _timeframeMinutes(timeframe);

      if (minutes <= 1) {
        return candles;
      }

      return _aggregateCandles(candles, minutes);
    } catch (e) {
      debugPrint('[Quanttora] Historical candle error: $e');

      return <Candle>[];
    }
  }

  List<Candle> _aggregateCandles(List<Candle> source, int minutes) {
    if (source.isEmpty || minutes <= 1) {
      return source;
    }

    final result = <Candle>[];

    final groups = <DateTime, List<Candle>>{};

    for (final candle in source) {
      final time = candle.time;

      final bucketMinute = (time.minute ~/ minutes) * minutes;

      final bucket = DateTime(
        time.year,
        time.month,
        time.day,
        time.hour,
        bucketMinute,
      );

      groups.putIfAbsent(bucket, () => <Candle>[]);

      groups[bucket]!.add(candle);
    }

    final keys = groups.keys.toList()..sort();

    for (final key in keys) {
      final group = groups[key]!;

      group.sort((a, b) => a.time.compareTo(b.time));

      if (group.isEmpty) {
        continue;
      }

      double high = group.first.high;

      double low = group.first.low;

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

  String _apiIntervalFor(String timeframe) {
    switch (timeframe.trim().toLowerCase()) {
      case '30 min':
        return '30minute';

      case '1 day':
        return 'day';

      default:
        return '1minute';
    }
  }

  int _timeframeMinutes(String timeframe) {
    switch (timeframe.trim().toLowerCase()) {
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

  String _dashboardKey(String market) {
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

  String _formatDate(DateTime date) {
    final year = date.year.toString();

    final month = date.month.toString().padLeft(2, '0');

    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
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

      optionChain: const OptionChain(
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

      sectorStrength: const SectorStrength(
        name: '-',
        strength: 0,
        leading: false,
      ),
    );
  }
}

class _OptionAnalytics {
  final OptionChain optionChain;
  final OIData oiData;

  const _OptionAnalytics({required this.optionChain, required this.oiData});

  factory _OptionAnalytics.empty() {
    return const _OptionAnalytics(
      optionChain: OptionChain(
        pcr: 0,
        maxCallOI: 0,
        maxPutOI: 0,
        callVolume: 0,
        putVolume: 0,
      ),
      oiData: OIData(
        callOIChange: 0,
        putOIChange: 0,
        callWriting: 0,
        putWriting: 0,
      ),
    );
  }
}