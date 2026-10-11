import 'dart:convert';

import 'package:backend/integrations/zerodha/zerodha_broker_service.dart';
import 'package:backend/services/broker_service.dart';

class ZerodhaOptionChainService {
  ZerodhaOptionChainService._();
  static final ZerodhaOptionChainService instance =
      ZerodhaOptionChainService._();

  final ZerodhaBrokerService _broker = ZerodhaBrokerService();
  final Map<String, ({DateTime fetchedAt, List<Map<String, String>> rows})>
  _cache = {};
  static const Duration _cacheTtl = Duration(hours: 6);

  Future<Map<String, dynamic>> getOptionContracts({
    required String instrumentKey,
    String? expiryDate,
  }) async {
    final spec = _resolveUnderlying(instrumentKey);
    final rows = await _loadRows(spec.exchange);
    var contracts = rows
        .where(
          (r) =>
              r['name'] == spec.name &&
              (r['instrument_type'] == 'CE' || r['instrument_type'] == 'PE') &&
              (r['expiry'] ?? '').isNotEmpty,
        )
        .toList();

    final today = _todayIso();
    contracts = contracts
        .where((r) => (r['expiry'] ?? '').compareTo(today) >= 0)
        .toList();
    if (expiryDate != null && expiryDate.trim().isNotEmpty) {
      final requested = _resolveExpiry(contracts, expiryDate.trim());
      contracts = contracts.where((r) => r['expiry'] == requested).toList();
    }
    contracts.sort((a, b) {
      final expiry = (a['expiry'] ?? '').compareTo(b['expiry'] ?? '');
      if (expiry != 0) return expiry;
      final strike = (double.tryParse(a['strike'] ?? '') ?? 0).compareTo(
        double.tryParse(b['strike'] ?? '') ?? 0,
      );
      if (strike != 0) return strike;
      return (a['instrument_type'] ?? '').compareTo(b['instrument_type'] ?? '');
    });
    return {
      'status': 'success',
      'broker': 'Zerodha',
      'instrumentKey': instrumentKey,
      'expiry': expiryDate,
      'count': contracts.length,
      'data': contracts
          .map(
            (r) => {
              'instrument_token':
                  int.tryParse(r['instrument_token'] ?? '') ?? 0,
              'instrumentToken': int.tryParse(r['instrument_token'] ?? '') ?? 0,
              'tradingsymbol': r['tradingsymbol'],
              'tradingSymbol': r['tradingsymbol'],
              'exchange': r['exchange'],
              'segment': r['segment'],
              'name': r['name'],
              'expiry': r['expiry'],
              'strike': double.tryParse(r['strike'] ?? '') ?? 0,
              'instrument_type': r['instrument_type'],
              'instrumentType': r['instrument_type'],
              'lot_size': int.tryParse(r['lot_size'] ?? '') ?? 0,
              'lotSize': int.tryParse(r['lot_size'] ?? '') ?? 0,
            },
          )
          .toList(),
    };
  }

  Future<Map<String, dynamic>> getOptionChain({
    required String instrumentKey,
    String expiryDate = 'current_week',
  }) async {
    final contractsResult = await getOptionContracts(
      instrumentKey: instrumentKey,
      expiryDate: expiryDate,
    );
    final contracts = (contractsResult['data'] as List)
        .cast<Map<String, dynamic>>();
    if (contracts.isEmpty) {
      return {
        'status': 'success',
        'broker': 'Zerodha',
        'instrumentKey': instrumentKey,
        'expiry': contractsResult['expiry'],
        'count': 0,
        'data': <dynamic>[],
      };
    }

    // Kite quote supports up to 500 instruments per request; keep each request below that.
    final quoteMap = <String, dynamic>{};
    final symbols = contracts
        .map((c) => '${c['exchange']}:${c['tradingsymbol']}')
        .toList();
    for (var i = 0; i < symbols.length; i += 400) {
      final batch = symbols.skip(i).take(400).join(',');
      final response = await _broker.getQuotes(
        BrokerService.instance.accessToken,
        batch,
      );
      final data = response['data'];
      if (data is Map) quoteMap.addAll(Map<String, dynamic>.from(data));
    }

    final byStrike = <String, Map<String, dynamic>>{};
    for (final c in contracts) {
      final strike = (c['strike'] as num).toDouble();
      final key = strike.toString();
      final row = byStrike.putIfAbsent(
        key,
        () => {'strike': strike, 'expiry': c['expiry'], 'CE': null, 'PE': null},
      );
      final symbol = '${c['exchange']}:${c['tradingsymbol']}';
      final q = quoteMap[symbol];
      final quote = q is Map
          ? Map<String, dynamic>.from(q)
          : <String, dynamic>{};
      final side = c['instrument_type'] == 'CE' ? 'CE' : 'PE';
      row[side] = {
        'instrument_token': c['instrument_token'],
        'tradingsymbol': c['tradingsymbol'],
        'last_price': quote['last_price'],
        'volume': quote['volume'],
        'oi': quote['oi'],
        'oi_day_high': quote['oi_day_high'],
        'oi_day_low': quote['oi_day_low'],
        'depth': quote['depth'],
      };
    }
    final data = byStrike.values.toList()
      ..sort(
        (a, b) => (a['strike'] as double).compareTo(b['strike'] as double),
      );
    return {
      'status': 'success',
      'broker': 'Zerodha',
      'instrumentKey': instrumentKey,
      'expiry': contractsResult['expiry'],
      'count': data.length,
      'data': data,
    };
  }

  ({String exchange, String name}) _resolveUnderlying(String key) {
    final value = key.trim().toUpperCase().replaceAll('_', ' ');
    if (value.contains('SENSEX') || value == 'BSE:SENSEX') {
      return (exchange: 'BFO', name: 'SENSEX');
    }
    if (value.contains('BANK NIFTY') || value.contains('NIFTY BANK')) {
      return (exchange: 'NFO', name: 'BANKNIFTY');
    }
    if (value.contains('FIN NIFTY') || value.contains('NIFTY FIN SERVICE')) {
      return (exchange: 'NFO', name: 'FINNIFTY');
    }
    if (value.contains('MIDCPNIFTY') || value.contains('MID CAP NIFTY')) {
      return (exchange: 'NFO', name: 'MIDCPNIFTY');
    }
    if (value.contains('NIFTY')) {
      return (exchange: 'NFO', name: 'NIFTY');
    }
    throw ArgumentError(
      'Unsupported option underlying "$key". Use NIFTY, BANKNIFTY, FINNIFTY, MIDCPNIFTY, or SENSEX.',
    );
  }

  Future<List<Map<String, String>>> _loadRows(String exchange) async {
    final cached = _cache[exchange];
    if (cached != null &&
        DateTime.now().difference(cached.fetchedAt) < _cacheTtl) {
      return cached.rows;
    }
    final token = BrokerService.instance.accessToken;
    final csv = await _broker.getInstrumentMasterCsv(token, exchange);
    final lines = const LineSplitter().convert(csv);
    if (lines.length < 2) {
      throw StateError('Zerodha $exchange instrument master is empty.');
    }
    final headers = _parseCsvLine(lines.first);
    final rows = <Map<String, String>>[];
    for (final line in lines.skip(1)) {
      if (line.trim().isEmpty) continue;
      final values = _parseCsvLine(line);
      final row = <String, String>{};
      for (var i = 0; i < headers.length && i < values.length; i++) {
        row[headers[i]] = values[i];
      }
      rows.add(row);
    }
    _cache[exchange] = (fetchedAt: DateTime.now(), rows: rows);
    return rows;
  }

  List<String> _parseCsvLine(String line) {
    final out = <String>[];
    final field = StringBuffer();
    var quoted = false;
    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        if (quoted && i + 1 < line.length && line[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          quoted = !quoted;
        }
      } else if (ch == ',' && !quoted) {
        out.add(field.toString());
        field.clear();
      } else {
        field.write(ch);
      }
    }
    out.add(field.toString());
    return out;
  }

  String _resolveExpiry(List<Map<String, String>> rows, String requested) {
    final dates =
        rows
            .map((r) => r['expiry'] ?? '')
            .where((d) => d.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    if (dates.isEmpty) throw StateError('No upcoming option contracts found.');
    final normalized = requested.toLowerCase();
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(requested)) {
      if (!dates.contains(requested)) {
        throw StateError('No Zerodha contracts for expiry $requested.');
      }
      return requested;
    }
    if (normalized == 'current_month' ||
        normalized == 'current-month' ||
        normalized == 'month' ||
        normalized == 'monthly') {
      final now = DateTime.now();
      final monthly = dates
          .where(
            (d) =>
                DateTime.parse(d).year == now.year &&
                DateTime.parse(d).month == now.month,
          )
          .toList();
      return monthly.isNotEmpty ? monthly.last : dates.first;
    }
    if (normalized == 'current_week' ||
        normalized == 'current-week' ||
        normalized == 'week' ||
        normalized == 'weekly') {
      return dates.first;
    }
    throw ArgumentError(
      'Invalid expiry "$requested". Use YYYY-MM-DD, current_week, or current_month.',
    );
  }

  String _todayIso() {
    final n = DateTime.now();
    return '${n.year.toString().padLeft(4, '0')}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }
}
