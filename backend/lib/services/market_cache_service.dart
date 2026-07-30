import 'package:backend/generated/market_data_v3.pb.dart';

class MarketCacheService {
  MarketCacheService._();

  static final MarketCacheService instance = MarketCacheService._();

  final Map<String, Feed> _feeds = {};

  void update(String key, Feed feed) {
    _feeds[key] = feed;
  }

  Feed? getFeed(String key) {
    return _feeds[key];
  }

  Map<String, Feed> getAllFeeds() {
    return Map.unmodifiable(_feeds);
  }

  bool contains(String key) {
    return _feeds.containsKey(key);
  }

  void clear() {
    _feeds.clear();
  }

  int get count => _feeds.length;
}