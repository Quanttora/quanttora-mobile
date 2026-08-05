import 'candle.dart';
import 'option_chain.dart';
import 'oi_data.dart';
import 'heat_map.dart';
import 'sector_strength.dart';

class MarketSnapshot {
  final List<Candle> candles;

  final OptionChain optionChain;

  final OIData oiData;

  final HeatMap heatMap;

  final SectorStrength sectorStrength;

  const MarketSnapshot({
    required this.candles,
    required this.optionChain,
    required this.oiData,
    required this.heatMap,
    required this.sectorStrength,
  });
}
