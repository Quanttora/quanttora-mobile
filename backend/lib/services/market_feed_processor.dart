import 'package:backend/generated/market_data_v3.pb.dart';
import 'package:backend/models/market_tick.dart';
import 'package:backend/services/market_store.dart';

class MarketFeedProcessor {
  MarketFeedProcessor._();

  static final MarketFeedProcessor instance = MarketFeedProcessor._();

  static const Map<String, String> _symbols = {
    // MAIN INDICES
    'NSE_INDEX|Nifty 50': 'NIFTY 50',
    'NSE_INDEX|Nifty Bank': 'BANK NIFTY',
    'BSE_INDEX|SENSEX': 'SENSEX',
    'NSE_INDEX|India VIX': 'INDIA VIX',

    // SECTOR INDICES
    'NSE_INDEX|Nifty Auto': 'NIFTY AUTO',
    'NSE_INDEX|Nifty FMCG': 'NIFTY FMCG',
    'NSE_INDEX|Nifty IT': 'NIFTY IT',
    'NSE_INDEX|Nifty Metal': 'NIFTY METAL',
    'NSE_INDEX|Nifty Pharma': 'NIFTY PHARMA',
    'NSE_INDEX|Nifty PSU Bank': 'NIFTY PSU BANK',
    'NSE_INDEX|Nifty Realty': 'NIFTY REALTY',

    // EXISTING WATCHLIST
    'NSE_EQ|INE002A01018': 'RELIANCE',
    'NSE_EQ|INE467B01029': 'TCS',
    'NSE_EQ|INE040A01034': 'HDFCBANK',
    'NSE_EQ|INE009A01021': 'INFY',
    'NSE_EQ|INE090A01021': 'ICICIBANK',
    'NSE_EQ|INE062A01020': 'SBIN',
    'NSE_EQ|INE397D01024': 'BHARTIARTL',
    'NSE_EQ|INE154A01025': 'ITC',
  };

  void process(FeedResponse response) {
    if (response.feeds.isEmpty) {
      return;
    }

    response.feeds.forEach((instrumentKey, feed) {
      // ------------------------------------------------------------
      // IMPORTANT
      //
      // Do NOT reject instruments that are not in the static map.
      //
      // Discover can search any Upstox instrument and subscribe to it
      // dynamically. Those instruments must also reach MarketStore.
      // ------------------------------------------------------------

      final symbol = _getSymbol(
        instrumentKey,
      );

      double? ltp;
      double previousClose = 0;

      double bidPrice = 0;
      double askPrice = 0;

      int bidQuantity = 0;
      int askQuantity = 0;

      int volume = 0;
      double averageTradedPrice = 0;

      // ------------------------------------------------------------
      // FULL FEED
      // ------------------------------------------------------------

      if (feed.hasFullFeed()) {
        final full = feed.fullFeed;

        // INDEX FULL FEED
        if (full.hasIndexFF()) {
          final index = full.indexFF;

          if (index.hasLtpc()) {
            ltp = index.ltpc.ltp;
            previousClose = index.ltpc.cp;
          }
        }

        // EQUITY / MARKET FULL FEED
        else if (full.hasMarketFF()) {
          final market = full.marketFF;

          if (market.hasLtpc()) {
            ltp = market.ltpc.ltp;
            previousClose = market.ltpc.cp;
          }

          if (market.hasVtt()) {
            volume = market.vtt.toInt();
          }

          if (market.hasAtp()) {
            averageTradedPrice = market.atp;
          }

          if (market.marketLevel.bidAskQuote.isNotEmpty) {
            final level1 =
                market.marketLevel.bidAskQuote.first;

            bidPrice = level1.bidP.toDouble();
            askPrice = level1.askP.toDouble();

            bidQuantity = level1.bidQ.toInt();
            askQuantity = level1.askQ.toInt();
          }
        }
      }

      // ------------------------------------------------------------
      // LTPC FEED
      // ------------------------------------------------------------

      else if (feed.hasLtpc()) {
        ltp = feed.ltpc.ltp;
        previousClose = feed.ltpc.cp;
      }

      // ------------------------------------------------------------
      // Nothing useful in this feed frame
      // ------------------------------------------------------------

      if (ltp == null) {
        return;
      }

      final change = ltp - previousClose;

      final changePercent = previousClose > 0
          ? (change / previousClose) * 100
          : 0.0;

      // ------------------------------------------------------------
      // Store the tick
      // ------------------------------------------------------------

      final tick = MarketTick(
        instrumentKey: instrumentKey,
        symbol: symbol,
        ltp: ltp,
        previousClose: previousClose,
        change: change,
        changePercent: changePercent,
        bidPrice: bidPrice,
        askPrice: askPrice,
        bidQuantity: bidQuantity,
        askQuantity: askQuantity,
        volume: volume,
        averageTradedPrice: averageTradedPrice,
        vwap: 0.0,
        timestamp: DateTime.now(),
      );

      MarketStore.instance.update(tick);

      // ------------------------------------------------------------
      // Debug logging
      // ------------------------------------------------------------

      print(
        '${tick.symbol.padRight(20)} '
        '[$instrumentKey] '
        'LTP:${tick.ltp.toStringAsFixed(2)} '
        'Change:${tick.change >= 0 ? '+' : ''}'
        '${tick.change.toStringAsFixed(2)} '
        '(${tick.changePercent >= 0 ? '+' : ''}'
        '${tick.changePercent.toStringAsFixed(2)}%) '
        'Bid:${tick.bidPrice}(${tick.bidQuantity}) '
        'Ask:${tick.askPrice}(${tick.askQuantity}) '
        'Volume:${tick.volume} '
        'ATP:${tick.averageTradedPrice.toStringAsFixed(2)}',
      );
    });
  }

  String _getSymbol(String instrumentKey) {
    // Known instruments get their friendly symbol.
    final knownSymbol = _symbols[instrumentKey];

    if (knownSymbol != null) {
      return knownSymbol;
    }

    // ------------------------------------------------------------
    // Dynamically searched instruments
    //
    // Example:
    // NSE_EQ|INE614G01033
    //
    // We don't reject them anymore. Until Discover supplies the
    // trading symbol metadata to MarketFeedProcessor, use the
    // instrument key suffix as a safe fallback.
    // ------------------------------------------------------------

    final separatorIndex = instrumentKey.indexOf('|');

    if (separatorIndex >= 0 &&
        separatorIndex < instrumentKey.length - 1) {
      return instrumentKey.substring(separatorIndex + 1);
    }

    return instrumentKey;
  }
}