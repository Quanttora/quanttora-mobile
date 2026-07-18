import 'package:dio/dio.dart';

import 'api_client.dart';

class MarketService {
  const MarketService();

  Future<Response> getQuote(String symbol) async {
    return ApiClient.client.get(
      '/quote',
      queryParameters: {
        'symbol': symbol,
        'apikey': ApiClient.apiKey,
      },
    );
  }
}