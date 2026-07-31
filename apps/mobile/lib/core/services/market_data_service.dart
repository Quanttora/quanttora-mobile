import '../market_data/models/candle.dart';
import '../market_data/models/heat_map.dart';
import '../market_data/models/market_snapshot.dart';
import '../market_data/models/oi_data.dart';
import '../market_data/models/option_chain.dart';
import '../market_data/models/sector_strength.dart';
import '../network/api_client.dart';

class MarketDataService {
  final ApiClient _api = ApiClient.instance;

  Future<MarketSnapshot> fetchSnapshot({
    required String market,
  }) async {

    final response = await _api.get(
      "/market/dashboard",
    );

    final indices =
        response["indices"] as Map<String, dynamic>;

    final nifty =
        indices["nifty"] as Map<String, dynamic>?;

    final bankNifty =
        indices["bankNifty"] as Map<String, dynamic>?;

    final sensex =
        indices["sensex"] as Map<String, dynamic>?;

    return MarketSnapshot(
      candles: [
        Candle(
          open: 0,
          high: 0,
          low: 0,
          close: (nifty?["ltp"] ?? 0).toDouble(),
          volume: 0,
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

      heatMap: HeatMap(
        advancing:
            response["marketOpen"] == true ? 34 : 0,
        declining:
            response["marketOpen"] == true ? 16 : 0,
        strongestSector: "Banking",
        weakestSector: "FMCG",
      ),

      sectorStrength: SectorStrength(
        name: "Banking",
        strength: 92,
        leading: true,
      ),
          );
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is double) return value;

    if (value is int) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is double) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }
    MarketSnapshot emptySnapshot() {
    return MarketSnapshot(
      candles: [
        Candle(
          open: 0,
          high: 0,
          low: 0,
          close: 0,
          volume: 0,
          time: DateTime.now(),
        ),
      ],
      optionChain: const OptionChain(
        pcr: 0,
        maxCallOI: 0,
        maxPutOI: 0,
        callVolume: 0,
        putVolume: 0,
      ),
      oiData: const OIData(
        callOIChange: 0,
        putOIChange: 0,
        callWriting: 0,
        putWriting: 0,
      ),
      heatMap: const HeatMap(
        advancing: 0,
        declining: 0,
        strongestSector: "-",
        weakestSector: "-",
      ),
      sectorStrength: const SectorStrength(
        name: "-",
        strength: 0,
        leading: false,
      ),
    );
  }
}