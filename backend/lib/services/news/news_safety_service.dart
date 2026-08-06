import 'marketaux_news_service.dart';

class NewsSafetyResult {
  final bool dataAvailable;
  final bool highImpactNews;
  final String reason;
  final List<String> matchedHeadlines;

  const NewsSafetyResult({
    required this.dataAvailable,
    required this.highImpactNews,
    required this.reason,
    required this.matchedHeadlines,
  });

  Map<String, dynamic> toJson() {
    return {
      'dataAvailable': dataAvailable,
      'highImpactNews': highImpactNews,
      'reason': reason,
      'matchedHeadlines': matchedHeadlines,
    };
  }
}

class NewsSafetyService {
  NewsSafetyService({MarketauxNewsService? newsService})
    : _newsService = newsService ?? MarketauxNewsService();

  final MarketauxNewsService _newsService;

  static const List<String> _highImpactKeywords = [
    'rbi',
    'reserve bank of india',
    'repo rate',
    'interest rate',
    'rate cut',
    'rate hike',
    'monetary policy',
    'federal reserve',
    'fed rate',
    'inflation',
    'cpi',
    'gdp',
    'budget',
    'sebi',
    'war',
    'missile',
    'attack',
    'sanction',
    'geopolitical',
    'emergency',
    'market crash',
    'trading halt',
  ];

  Future<NewsSafetyResult> evaluate() async {
    try {
      final news = await _newsService.fetchIndianMarketNews(limit: 20);

      final now = DateTime.now().toUtc();

      final recentNews = news
          .where((item) {
            final publishedAt = item.publishedAt;

            if (publishedAt == null) {
              return false;
            }

            final age = now.difference(publishedAt.toUtc());

            return !age.isNegative && age <= const Duration(hours: 6);
          })
          .toList(growable: false);

      final matchedHeadlines = <String>[];

      for (final item in recentNews) {
        final normalizedTitle = item.title.toLowerCase();

        final highImpact = _highImpactKeywords.any(normalizedTitle.contains);

        if (highImpact) {
          matchedHeadlines.add(item.title);
        }
      }

      if (matchedHeadlines.isNotEmpty) {
        return NewsSafetyResult(
          dataAvailable: true,
          highImpactNews: true,
          reason: 'Recent high-impact market-moving news risk detected.',
          matchedHeadlines: matchedHeadlines,
        );
      }

      return const NewsSafetyResult(
        dataAvailable: true,
        highImpactNews: false,
        reason: 'No recent high-impact market-moving news risk detected.',
        matchedHeadlines: [],
      );
    } catch (_) {
      // Fail closed. A provider/network/configuration failure must
      // never be interpreted as "no news risk".
      return const NewsSafetyResult(
        dataAvailable: false,
        highImpactNews: false,
        reason: 'Reliable news-safety data is currently unavailable.',
        matchedHeadlines: [],
      );
    }
  }
}
