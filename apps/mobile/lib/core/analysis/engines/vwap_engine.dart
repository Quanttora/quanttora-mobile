import '../../market_data/models/candle.dart';

class VWAPResult {
  final bool aboveVWAP;
  final double value;
  final int score;
  final String status;
  final String reason;

  const VWAPResult({
    required this.aboveVWAP,
    required this.value,
    required this.score,
    required this.status,
    required this.reason,
  });
}

class VWAPEngine {
  static VWAPResult analyze({
    required List<Candle> candles,
    required String direction,
  }) {
    if (candles.isEmpty) {
      return const VWAPResult(
        aboveVWAP: false,
        value: 0,
        score: 0,
        status: 'Insufficient Data',
        reason: 'Not enough candle data to calculate VWAP.',
      );
    }

    // ============================================================
    // INDEX INSTRUMENT
    // ============================================================
    //
    // MarketDataService marks index candles with volume = -1.
    //
    // NIFTY 50, BANK NIFTY, SENSEX and similar index instruments
    // do not provide exchange-traded volume for the underlying
    // index itself.
    //
    // Therefore we must NOT manufacture volume or calculate a
    // misleading VWAP.
    //
    // ============================================================

    final isIndexInstrument = candles.any((candle) => candle.volume < 0);

    if (isIndexInstrument) {
      return const VWAPResult(
        aboveVWAP: false,
        value: 0,
        score: 0,
        status: 'N/A (Index Instrument)',
        reason:
            'VWAP is not available because exchange-traded volume '
            'is not provided for index instruments.',
      );
    }

    // ============================================================
    // VALID VOLUME DATA
    // ============================================================

    double cumulativePriceVolume = 0;
    double cumulativeVolume = 0;

    for (final candle in candles) {
      // Ignore candles without usable volume.
      if (candle.volume <= 0) {
        continue;
      }

      final typicalPrice = (candle.high + candle.low + candle.close) / 3;

      cumulativePriceVolume += typicalPrice * candle.volume;

      cumulativeVolume += candle.volume;
    }

    // ============================================================
    // NO USABLE VOLUME
    // ============================================================

    if (cumulativeVolume <= 0) {
      return const VWAPResult(
        aboveVWAP: false,
        value: 0,
        score: 0,
        status: 'Volume Unavailable',
        reason:
            'VWAP cannot be calculated because reliable '
            'candle volume is unavailable.',
      );
    }

    // ============================================================
    // VWAP
    // ============================================================

    final vwap = cumulativePriceVolume / cumulativeVolume;

    final currentPrice = candles.last.close;

    final aboveVWAP = currentPrice > vwap;

    final isCall = direction.toUpperCase() == 'CALL';

    // ============================================================
    // DIRECTIONAL SCORING
    // ============================================================

    late final int score;
    late final String status;
    late final String reason;

    if (isCall) {
      if (aboveVWAP) {
        score = 90;
        status = 'Above VWAP';

        reason =
            'Price ${currentPrice.toStringAsFixed(2)} '
            'is above VWAP '
            '${vwap.toStringAsFixed(2)}, '
            'supporting the CALL direction.';
      } else {
        score = 40;
        status = 'Below VWAP';

        reason =
            'Price ${currentPrice.toStringAsFixed(2)} '
            'is below VWAP '
            '${vwap.toStringAsFixed(2)}, '
            'which does not support the CALL direction.';
      }
    } else {
      if (!aboveVWAP) {
        score = 90;
        status = 'Below VWAP';

        reason =
            'Price ${currentPrice.toStringAsFixed(2)} '
            'is below VWAP '
            '${vwap.toStringAsFixed(2)}, '
            'supporting the PUT direction.';
      } else {
        score = 40;
        status = 'Above VWAP';

        reason =
            'Price ${currentPrice.toStringAsFixed(2)} '
            'is above VWAP '
            '${vwap.toStringAsFixed(2)}, '
            'which does not support the PUT direction.';
      }
    }

    return VWAPResult(
      aboveVWAP: aboveVWAP,
      value: vwap,
      score: score,
      status: status,
      reason: reason,
    );
  }
}
