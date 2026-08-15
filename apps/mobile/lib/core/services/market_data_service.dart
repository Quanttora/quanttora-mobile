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

    final bidQuantity = (marketData?['bidQuantity'] as num?)?.toInt() ?? 0;

    final askQuantity = (marketData?['askQuantity'] as num?)?.toInt() ?? 0;

    final finalCandles = List<Candle>.from(candles);

    if (livePrice > 0 && finalCandles.isEmpty) {
      finalCandles.add(
        Candle(
          open: livePrice,
          high: livePrice,
          low: livePrice,
          close: livePrice,
          volume: _isIndexMarket(market) ? -1 : 0,
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

    try {
      final encodedInstrument = Uri.encodeQueryComponent(instrumentKey);

      // ---------------------------------------------------------
      // STEP 1:
      // Get available option contracts.
      // ---------------------------------------------------------

      final contractsResponse = await _api.get(
        '/broker/option-contracts'
        '?instrumentKey=$encodedInstrument',
      );

      final contracts = contractsResponse['data'] as List<dynamic>?;

      if (contracts == null || contracts.isEmpty) {
        debugPrint('[Quanttora] No option contracts found.');

        return _OptionAnalytics.empty();
      }

      final expiries = <DateTime>[];

      for (final item in contracts) {
        if (item is! Map) {
          continue;
        }

        final expiry = DateTime.tryParse(item['expiry']?.toString() ?? '');

        if (expiry != null) {
          expiries.add(expiry);
        }
      }

      if (expiries.isEmpty) {
        debugPrint('[Quanttora] No valid expiries found.');

        return _OptionAnalytics.empty();
      }

      expiries.sort();

      final expiryDate = _formatDate(expiries.first);

      debugPrint(
        '[Quanttora] Selected expiry: '
        '$expiryDate',
      );

      // ---------------------------------------------------------
      // STEP 2:
      // Get Quanttora's real backend analysis.
      // ---------------------------------------------------------

      final analysisResponse = await _api.get(
        '/broker/option-analysis'
        '?instrumentKey=$encodedInstrument'
        '&expiry=$expiryDate',
      );

      final analysis = analysisResponse['analysis'] as Map<String, dynamic>?;

      if (analysis == null) {
        debugPrint('[Quanttora] Analysis data unavailable.');

        return _OptionAnalytics.empty();
      }

      // ---------------------------------------------------------
      // STEP 3:
      // Extract support / resistance.
      // ---------------------------------------------------------

      final support =
          analysis['support'] as Map<String, dynamic>? ?? <String, dynamic>{};

      final resistance =
          analysis['resistance'] as Map<String, dynamic>? ??
          <String, dynamic>{};

      final totals =
          analysis['totals'] as Map<String, dynamic>? ?? <String, dynamic>{};

      // ---------------------------------------------------------
      // STEP 4:
      // Totals
      // ---------------------------------------------------------

      final pcr = _toDouble(totals['pcr']);

      final callOI = _toDouble(totals['callOi']);

      final putOI = _toDouble(totals['putOi']);

      final callOIChange = _toDouble(totals['callOiChange']);

      final putOIChange = _toDouble(totals['putOiChange']);

      final callVolume = _toDouble(totals['callVolume']);

      final putVolume = _toDouble(totals['putVolume']);

      // ---------------------------------------------------------
      // STEP 5:
      // Support / Resistance
      // ---------------------------------------------------------

      final supportStrike = _toDouble(support['strike']);

      final supportOI = _toDouble(support['oi']);

      final resistanceStrike = _toDouble(resistance['strike']);

      final resistanceOI = _toDouble(resistance['oi']);

      // ---------------------------------------------------------
      // STEP 6:
      // Spot / ATM
      // ---------------------------------------------------------

      final spotPrice = _toDouble(analysis['spotPrice']);

      final atmStrike = _toDouble(analysis['atmStrike']);

      // ---------------------------------------------------------
      // STEP 7:
      // Quanttora direction / score
      // ---------------------------------------------------------

      final direction =
          analysis['direction']?.toString().toUpperCase() ?? 'NEUTRAL';

      final directionScore = _toDouble(analysis['directionScore']);

      final qScore = _toDouble(analysis['qScore']);

      final rowsAnalyzed = (analysis['rowsAnalyzed'] as num?)?.toInt() ?? 0;

      // ---------------------------------------------------------
      // DEBUG
      // ---------------------------------------------------------

      debugPrint('[Quanttora] REAL OPTION ANALYSIS');

      debugPrint('[Quanttora] Market: $market');

      debugPrint('[Quanttora] Expiry: $expiryDate');

      debugPrint('[Quanttora] Spot: $spotPrice');

      debugPrint('[Quanttora] ATM: $atmStrike');

      debugPrint(
        '[Quanttora] Support: '
        '$supportStrike',
      );

      debugPrint(
        '[Quanttora] Resistance: '
        '$resistanceStrike',
      );

      debugPrint(
        '[Quanttora] PCR: '
        '${pcr.toStringAsFixed(2)}',
      );

      debugPrint(
        '[Quanttora] Direction: '
        '$direction',
      );

      debugPrint(
        '[Quanttora] Direction Score: '
        '${directionScore.toStringAsFixed(1)}',
      );

      debugPrint(
        '[Quanttora] Q-Score: '
        '${qScore.toStringAsFixed(1)}',
      );

      debugPrint(
        '[Quanttora] Rows: '
        '$rowsAnalyzed',
      );

      // ---------------------------------------------------------
      // STEP 8:
      // Build Flutter model using REAL backend data.
      // ---------------------------------------------------------

      return _OptionAnalytics(
        optionChain: OptionChain(
          pcr: pcr,

          maxCallOI: resistanceStrike,

          maxPutOI: supportStrike,

          callVolume: callVolume,

          putVolume: putVolume,

          spotPrice: spotPrice,

          atmStrike: atmStrike,

          supportStrike: supportStrike,

          supportOI: supportOI,

          resistanceStrike: resistanceStrike,

          resistanceOI: resistanceOI,

          callOI: callOI,

          putOI: putOI,

          callOIChange: callOIChange,

          putOIChange: putOIChange,

          direction: direction,

          directionScore: directionScore,

          qScore: qScore,

          expiry: expiryDate,

          rowsAnalyzed: rowsAnalyzed,
        ),
        oiData: OIData(
          callOIChange: callOIChange,

          putOIChange: putOIChange,

          callWriting: callOIChange > 0 ? callOIChange : 0,

          putWriting: putOIChange > 0 ? putOIChange : 0,
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
      debugPrint(
        '[Quanttora] Unsupported market: '
        '$market',
      );

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
        debugPrint(
          '[Quanttora] Historical API '
          'returned 0 candles.',
        );

        return <Candle>[];
      }

      debugPrint(
        '[Quanttora] Real 1-minute candles '
        'received: ${rawCandles.length}',
      );

      final candles = <Candle>[];

      // ==========================================================
      // IMPORTANT:
      // Index instruments do not have exchange-traded volume.
      //
      // VolumeEngine uses -1 to identify an index instrument.
      // Upstox historical candles may return 0/null for volume,
      // so we explicitly mark index candles as -1 here.
      // ==========================================================

      final isIndexInstrument = _isIndexMarket(market);

      for (final raw in rawCandles) {
        if (raw is! List || raw.length < 6) {
          continue;
        }

        final time = DateTime.tryParse(raw[0].toString());

        if (time == null) {
          continue;
        }

        final apiVolume = _toDouble(raw[5]);

        final candleVolume = isIndexInstrument ? -1.0 : apiVolume;

        candles.add(
          Candle(
            open: _toDouble(raw[1]),
            high: _toDouble(raw[2]),
            low: _toDouble(raw[3]),
            close: _toDouble(raw[4]),
            volume: candleVolume,
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
      debugPrint(
        '[Quanttora] Historical candle error: '
        '$e',
      );

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

      // For index instruments every candle has volume -1.
      // Keep the index marker instead of summing -1 values.
      final isIndexCandle = group.any((candle) => candle.volume < 0);

      for (final candle in group) {
        if (candle.high > high) {
          high = candle.high;
        }

        if (candle.low < low) {
          low = candle.low;
        }

        if (!isIndexCandle) {
          volume += candle.volume;
        }
      }

      result.add(
        Candle(
          open: group.first.open,
          high: high,
          low: low,
          close: group.last.close,
          volume: isIndexCandle ? -1 : volume,
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

  bool _isIndexMarket(String market) {
    switch (market.trim().toUpperCase()) {
      case 'NIFTY':
      case 'NIFTY 50':
      case 'BANKNIFTY':
      case 'BANK NIFTY':
      case 'SENSEX':
      case 'INDIA VIX':
        return true;

      default:
        return false;
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

    if (value is num) {
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
