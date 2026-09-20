import 'dart:convert';

import 'package:http/http.dart' as http;

class UpstoxInstrumentSearchService {
  static const String _baseUrl = 'https://api.upstox.com/v2';

  Future<Map<String, dynamic>> search({
    required String accessToken,
    required String query,
    String exchanges = 'NSE',
    String segments = 'EQ',
    String? instrumentTypes,
    String? expiry,
    int? atmOffset,
    int pageNumber = 1,
    int records = 30,
  }) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      throw ArgumentError('query is required');
    }

    if (trimmedQuery.length > 50) {
      throw ArgumentError('query cannot exceed 50 characters');
    }

    final safePage = pageNumber < 1 ? 1 : pageNumber;
    final safeRecords = records.clamp(1, 30);

    final queryParameters = <String, String>{
      'query': trimmedQuery,
      'exchanges': exchanges,
      'segments': segments,
      'page_number': safePage.toString(),
      'records': safeRecords.toString(),
    };

    if (instrumentTypes != null &&
        instrumentTypes.trim().isNotEmpty) {
      queryParameters['instrument_types'] =
          instrumentTypes.trim();
    }

    if (expiry != null && expiry.trim().isNotEmpty) {
      queryParameters['expiry'] = expiry.trim();
    }

    if (atmOffset != null) {
      queryParameters['atm_offset'] = atmOffset.toString();
    }

    final uri = Uri.parse(
      '$_baseUrl/instruments/search',
    ).replace(
      queryParameters: queryParameters,
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    final decoded = _decodeResponse(response);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Upstox instrument search failed '
        '(${response.statusCode}): '
        '${decoded['message'] ?? decoded}',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'Invalid response from Upstox instrument search.',
      );
    }

    return decoded;
  }

  dynamic _decodeResponse(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {
        'status': 'error',
        'message': response.body,
      };
    }
  }
}