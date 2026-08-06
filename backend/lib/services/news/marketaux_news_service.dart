import 'dart:convert';
import 'dart:io';

import '../../core/config/app_config.dart';

class MarketNewsItem {
  final String title;
  final String source;
  final String url;
  final DateTime? publishedAt;

  const MarketNewsItem({
    required this.title,
    required this.source,
    required this.url,
    required this.publishedAt,
  });
}

class MarketauxNewsService {
  static const String _host = 'api.marketaux.com';

  Future<List<MarketNewsItem>> fetchIndianMarketNews({int limit = 10}) async {
    final token = AppConfig.marketauxApiToken.trim();

    if (token.isEmpty) {
      throw StateError('MARKETAUX_API_TOKEN is not configured.');
    }

    final uri = Uri.https(_host, '/v1/news/all', {
      'api_token': token,
      'countries': 'in',
      'language': 'en',
      'limit': limit.toString(),
    });

    final client = HttpClient();

    try {
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final response = await request.close();

      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Marketaux request failed '
          '(${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid Marketaux response.');
      }

      final data = decoded['data'];

      if (data is! List) {
        throw const FormatException(
          'Marketaux response does not contain news data.',
        );
      }

      return data
          .whereType<Map>()
          .map((item) {
            final json = Map<String, dynamic>.from(item);

            final sourceValue = json['source'];

            String source = '';

            if (sourceValue is String) {
              source = sourceValue;
            } else if (sourceValue is Map) {
              source = sourceValue['name']?.toString() ?? '';
            }

            return MarketNewsItem(
              title: json['title']?.toString() ?? '',
              source: source,
              url: json['url']?.toString() ?? '',
              publishedAt: DateTime.tryParse(
                json['published_at']?.toString() ?? '',
              ),
            );
          })
          .where((item) => item.title.trim().isNotEmpty)
          .toList(growable: false);
    } finally {
      client.close(force: true);
    }
  }
}
