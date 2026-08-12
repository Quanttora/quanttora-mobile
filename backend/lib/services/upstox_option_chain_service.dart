import 'dart:convert';

import 'package:backend/interfaces/broker/broker_option_chain_interface.dart';
import 'package:backend/services/broker_service.dart';
import 'package:http/http.dart' as http;

class UpstoxOptionChainService
    implements BrokerOptionChainInterface {
  UpstoxOptionChainService._();

  static final UpstoxOptionChainService instance =
      UpstoxOptionChainService._();

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

    final uri = Uri.parse(_optionChainBaseUrl).replace(
      queryParameters: {
        'instrument_key': instrumentKey,
        'expiry_date': expiryDate,
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
      throw Exception(
        'Invalid Option Chain response.',
      );
    }

    if (decoded['status'] != 'success') {
      throw Exception(
        'Upstox Option Chain returned '
        'status: ${decoded['status']}',
      );
    }

    final data = decoded['data'];

    if (data is! List) {
      throw Exception(
        'Option Chain data is unavailable.',
      );
    }

    return {
      'status': 'success',
      'instrumentKey': instrumentKey,
      'expiry': expiryDate,
      'count': data.length,
      'data': data,
    };
  }

  Future<Map<String, dynamic>> getOptionContracts({
    required String instrumentKey,
    String? expiryDate,
  }) async {
    final broker = BrokerService.instance;

    if (!broker.hasValidSession()) {
      throw StateError('Broker is not connected.');
    }

    final queryParameters = <String, String>{
      'instrument_key': instrumentKey,
    };

    if (expiryDate != null &&
        expiryDate.trim().isNotEmpty) {
      queryParameters['expiry_date'] =
          expiryDate.trim();
    }

    final uri =
        Uri.parse(_optionContractBaseUrl).replace(
      queryParameters: queryParameters,
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ${broker.accessToken}',
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
      throw Exception(
        'Invalid Option Contracts response.',
      );
    }

    if (decoded['status'] != 'success') {
      throw Exception(
        'Upstox Option Contracts returned '
        'status: ${decoded['status']}',
      );
    }

    final data = decoded['data'];

    if (data is! List) {
      throw Exception(
        'Option Contracts data is unavailable.',
      );
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