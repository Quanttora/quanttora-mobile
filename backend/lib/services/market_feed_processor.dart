import 'package:backend/generated/market_data_v3.pb.dart';
import 'package:backend/models/market_tick.dart';
import 'package:backend/services/market_store.dart';

class MarketFeedProcessor {
  MarketFeedProcessor._();

  static final MarketFeedProcessor instance =
      MarketFeedProcessor._();

  static const Map<String, String> _symbols = {
    // MAIN INDICES
    'NSE_INDEX|Nifty 50': 'NIFTY 50',
    'NSE_INDEX|Nifty Bank': 'BANK NIFTY',
    'BSE_INDEX|SENSEX': 'SENSEX',
    'NSE_INDEX|India VIX': 'INDIA VIX',

    // VERIFIED REAL NSE SECTOR INDICES
    'NSE_INDEX|Nifty Auto': 'NIFTY AUTO',
    'NSE_INDEX|Nifty FMCG': 'NIFTY FMCG',
    'NSE_INDEX|Nifty IT': 'NIFTY IT',
    'NSE_INDEX|Nifty Metal': 'NIFTY METAL',
    'NSE_INDEX|Nifty Pharma': 'NIFTY PHARMA',
    'NSE_INDEX|Nifty PSU Bank': 'NIFTY PSU BANK',
    'NSE_INDEX|Nifty Realty': 'NIFTY REALTY',
  };

  void process(FeedResponse response) {
    if (response.feeds.isEmpty) {
      return;
    }

    response.feeds.forEach(
      (instrumentKey, feed) {
        if (!_symbols.containsKey(instrumentKey)) {
          return;
        }

        double? ltp;
        double change = 0;

        if (feed.hasFullFeed()) {
          final full = feed.fullFeed;

          if (full.hasIndexFF()) {
            final index = full.indexFF;

            if (index.hasLtpc()) {
              ltp = index.ltpc.ltp;
              change = index.ltpc.cp;
            }
          } else if (full.hasMarketFF()) {
            final market = full.marketFF;

            if (market.hasLtpc()) {
              ltp = market.ltpc.ltp;
              change = market.ltpc.cp;
            }
          }
        } else if (feed.hasLtpc()) {
          ltp = feed.ltpc.ltp;
          change = feed.ltpc.cp;
        }

        if (ltp == null) {
          return;
        }

        final tick = MarketTick(
          instrumentKey: instrumentKey,
          symbol: _symbols[instrumentKey]!,
          ltp: ltp,
          change: change,
          timestamp: DateTime.now(),
        );

        MarketStore.instance.update(tick);

        print(
          '${tick.symbol.padRight(16)} '
          'LTP: ${tick.ltp.toStringAsFixed(2)} '
          'Close: ${tick.change.toStringAsFixed(2)}',
        );
      },
    );
  }
}