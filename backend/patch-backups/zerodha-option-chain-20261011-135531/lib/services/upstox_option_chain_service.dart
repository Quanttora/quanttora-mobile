import 'dart:convert';

import 'package:backend/interfaces/broker/broker_option_chain_interface.dart';
import 'package:backend/services/broker_service.dart';
import 'package:http/http.dart' as http;

class UpstoxOptionChainService implements BrokerOptionChainInterface {
  UpstoxOptionChainService._();

  static final UpstoxOptionChainService instance = UpstoxOptionChainService._();

  static const String _optionChainBaseUrl =
      'https://api.upstox.com/v2/option/chain';

  static const String _optionContractBaseUrl =
      'https://api.upstox.com/v2/option/contract';

  @override
  Future<Map<String, dynamic>> getOptionChain({
    required String instrumentKey,
    String expiryDate = 'current_week',
  }) async {
    final broker = BrokerService.instance;

    if (!broker.hasValidSession()) {
      throw StateError('Broker is not connected.');
    }

    final resolvedExpiry = await _resolveExpiry(
      instrumentKey: instrumentKey,
      expiryDate: expiryDate,
    );

    final uri = Uri.parse(_optionChainBaseUrl).replace(
      queryParameters: {
        'instrument_key': instrumentKey,
        'expiry_date': resolvedExpiry,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${broker.accessToken}',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Upstox Option Chain failed '
        '(${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid Option Chain response.');
    }

    if (decoded['status'] != 'success') {
      throw Exception(
        'Upstox Option Chain returned '
        'status: ${decoded['status']}',
      );
    }

    final data = decoded['data'];

    if (data is! List) {
      throw Exception('Option Chain data is unavailable.');
    }

    return {
      'status': 'success',
      'instrumentKey': instrumentKey,
      'requestedExpiry': expiryDate,
      'expiry': resolvedExpiry,
      'count': data.length,
      'data': data,
    };
  }

  Future<String> _resolveExpiry({
    required String instrumentKey,
    required String expiryDate,
  }) async {
    final requested = expiryDate.trim();

    if (requested.isEmpty) {
      return _resolveExpiryFromContracts(
        instrumentKey: instrumentKey,
        mode: 'current_week',
      );
    }

    if (_isDate(requested)) {
      return requested;
    }

    final normalized = requested.toLowerCase();

    if (normalized == 'current_week' ||
        normalized == 'current-week' ||
        normalized == 'week' ||
        normalized == 'weekly') {
      return _resolveExpiryFromContracts(
        instrumentKey: instrumentKey,
        mode: 'current_week',
      );
    }

    if (normalized == 'current_month' ||
        normalized == 'current-month' ||
        normalized == 'month' ||
        normalized == 'monthly') {
      return _resolveExpiryFromContracts(
        instrumentKey: instrumentKey,
        mode: 'current_month',
      );
    }

    throw ArgumentError(
      'Invalid expiryDate "$expiryDate". '
      'Use YYYY-MM-DD, current_week, or current_month.',
    );
  }

  bool _isDate(String value) {
    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      return false;
    }

    final normalized =
        '${parsed.year.toString().padLeft(4, '0')}-'
        '${parsed.month.toString().padLeft(2, '0')}-'
        '${parsed.day.toString().padLeft(2, '0')}';

    return normalized == value;
  }

  Future<String> _resolveExpiryFromContracts({
    required String instrumentKey,
    required String mode,
  }) async {
    final contracts = await getOptionContracts(instrumentKey: instrumentKey);

    final rawData = contracts['data'];

    if (rawData is! List || rawData.isEmpty) {
      throw StateError('No option contracts found for $instrumentKey.');
    }

    final expiryDates = <DateTime>[];

    for (final item in rawData) {
      if (item is! Map) {
        continue;
      }

      final expiry = item['expiry'];

      if (expiry is! String || expiry.trim().isEmpty) {
        continue;
      }

      final parsed = DateTime.tryParse(expiry.trim());

      if (parsed == null) {
        continue;
      }

      final normalized = DateTime.utc(parsed.year, parsed.month, parsed.day);

      if (!expiryDates.contains(normalized)) {
        expiryDates.add(normalized);
      }
    }

    if (expiryDates.isEmpty) {
      throw StateError('No valid expiry dates found for $instrumentKey.');
    }

    expiryDates.sort();

    final today = DateTime.now();

    final todayDate = DateTime.utc(today.year, today.month, today.day);

    final futureExpiries = expiryDates
        .where((expiry) => !expiry.isBefore(todayDate))
        .toList();

    if (futureExpiries.isEmpty) {
      throw StateError('No upcoming option expiry found for $instrumentKey.');
    }

    if (mode == 'current_week') {
      return _formatDate(futureExpiries.first);
    }

    final monthlyExpiries = futureExpiries
        .where(
          (expiry) =>
              expiry.year == todayDate.year && expiry.month == todayDate.month,
        )
        .toList();

    if (monthlyExpiries.isNotEmpty) {
      return _formatDate(monthlyExpiries.last);
    }

    return _formatDate(futureExpiries.first);
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<Map<String, dynamic>> getOptionContracts({
    required String instrumentKey,
    String? expiryDate,
  }) async {
    final broker = BrokerService.instance;

    if (!broker.hasValidSession()) {
      throw StateError('Broker is not connected.');
    }

    final queryParameters = <String, String>{'instrument_key': instrumentKey};

    if (expiryDate != null && expiryDate.trim().isNotEmpty) {
      queryParameters['expiry_date'] = expiryDate.trim();
    }

    final uri = Uri.parse(
      _optionContractBaseUrl,
    ).replace(queryParameters: queryParameters);

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${broker.accessToken}',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Upstox Option Contracts failed '
        '(${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid Option Contracts response.');
    }

    if (decoded['status'] != 'success') {
      throw Exception(
        'Upstox Option Contracts returned '
        'status: ${decoded['status']}',
      );
    }

    final data = decoded['data'];

    if (data is! List) {
      throw Exception('Option Contracts data is unavailable.');
    }

    return {
      'status': 'success',
      'instrumentKey': instrumentKey,
      'expiry': expiryDate,
      'count': data.length,
      'data': data,
    };
  }
}
