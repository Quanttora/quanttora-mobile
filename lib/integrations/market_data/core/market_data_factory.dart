import '../twelve_data/twelve_data_adapter.dart';
import 'market_provider.dart';

class MarketDataFactory {
  const MarketDataFactory._();

  static MarketProvider create() {
    return TwelveDataAdapter();
  }
}