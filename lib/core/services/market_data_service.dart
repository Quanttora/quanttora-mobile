import '../market_data/models/candle.dart';
import '../market_data/models/heat_map.dart';
import '../market_data/models/market_snapshot.dart';
import '../market_data/models/oi_data.dart';
import '../market_data/models/option_chain.dart';
import '../market_data/models/sector_strength.dart';

class MarketDataService {
  Future<MarketSnapshot> fetchSnapshot({required String market}) async {
    // LIVE DATA WILL COME FROM:
    // Angel One
    // Zerodha
    // Upstox
    // Dhan
    // NSE

    return MarketSnapshot(
      candles: [
        Candle(
          open: 25000,
          high: 25110,
          low: 24970,
          close: 25095,
          volume: 1250000,
          time: DateTime.now(),
        ),
      ],

      optionChain: const OptionChain(
        pcr: 1.08,
        maxCallOI: 25200,
        maxPutOI: 25000,
        callVolume: 215000,
        putVolume: 198000,
      ),

      oiData: const OIData(
        callOIChange: 12000,
        putOIChange: 18000,
        callWriting: 8500,
        putWriting: 14500,
      ),

      heatMap: const HeatMap(
        advancing: 34,
        declining: 16,
        strongestSector: "Banking",
        weakestSector: "FMCG",
      ),

      sectorStrength: const SectorStrength(
        name: "Banking",
        strength: 92,
        leading: true,
      ),
    );
  }
}
