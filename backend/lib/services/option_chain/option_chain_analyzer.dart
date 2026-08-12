class OptionChainAnalyzer {
  OptionChainAnalyzer._();

  static final OptionChainAnalyzer instance =
      OptionChainAnalyzer._();

  Map<String, dynamic> analyze({
    required Map<String, dynamic> optionChain,
  }) {
    final data = optionChain['data'];

    if (data is! List || data.isEmpty) {
      throw Exception('Option chain data is empty.');
    }

    final rows = data
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();

    if (rows.isEmpty) {
      throw Exception('No valid option chain rows found.');
    }

    final spotPrice =
        _toDouble(rows.first['underlying_spot_price']);

    final expiry =
        rows.first['expiry']?.toString();

    rows.sort(
      (a, b) => _toDouble(a['strike_price']).compareTo(
        _toDouble(b['strike_price']),
      ),
    );

    final atmRow = rows.reduce(
      (a, b) {
        final aDistance =
            (_toDouble(a['strike_price']) - spotPrice).abs();

        final bDistance =
            (_toDouble(b['strike_price']) - spotPrice).abs();

        return aDistance <= bDistance ? a : b;
      },
    );

    final atmStrike =
        _toDouble(atmRow['strike_price']);

    Map<String, dynamic>? supportRow;
    Map<String, dynamic>? resistanceRow;

    double maxPutOi = 0;
    double maxCallOi = 0;

    for (final row in rows) {
      final strike =
          _toDouble(row['strike_price']);

      final call =
          _map(row['call_options']);

      final put =
          _map(row['put_options']);

      final callMarket =
          _map(call['market_data']);

      final putMarket =
          _map(put['market_data']);

      final callOi =
          _toDouble(callMarket['oi']);

      final putOi =
          _toDouble(putMarket['oi']);

      // Strongest PE OI below/at spot = support
      if (strike <= spotPrice &&
          putOi > maxPutOi) {
        maxPutOi = putOi;
        supportRow = row;
      }

      // Strongest CE OI above/at spot = resistance
      if (strike >= spotPrice &&
          callOi > maxCallOi) {
        maxCallOi = callOi;
        resistanceRow = row;
      }
    }

    final supportStrike = supportRow == null
        ? null
        : _toDouble(
            supportRow['strike_price'],
          );

    final resistanceStrike = resistanceRow == null
        ? null
        : _toDouble(
            resistanceRow['strike_price'],
          );

    double totalCallOi = 0;
    double totalPutOi = 0;

    double totalCallOiChange = 0;
    double totalPutOiChange = 0;

    double totalCallVolume = 0;
    double totalPutVolume = 0;

    for (final row in rows) {
      final call =
          _map(row['call_options']);

      final put =
          _map(row['put_options']);

      final callMarket =
          _map(call['market_data']);

      final putMarket =
          _map(put['market_data']);

      final callOi =
          _toDouble(callMarket['oi']);

      final putOi =
          _toDouble(putMarket['oi']);

      final callPrevOi =
          _toDouble(callMarket['prev_oi']);

      final putPrevOi =
          _toDouble(putMarket['prev_oi']);

      totalCallOi += callOi;
      totalPutOi += putOi;

      totalCallOiChange +=
          callOi - callPrevOi;

      totalPutOiChange +=
          putOi - putPrevOi;

      totalCallVolume +=
          _toDouble(callMarket['volume']);

      totalPutVolume +=
          _toDouble(putMarket['volume']);
    }

    final double calculatedPcr =
        totalCallOi == 0
            ? 0.0
            : totalPutOi / totalCallOi;

    final directionScore =
        _calculateDirectionalScore(
      spotPrice: spotPrice,
      supportStrike: supportStrike,
      resistanceStrike: resistanceStrike,
      calculatedPcr: calculatedPcr,
      totalCallOiChange:
          totalCallOiChange,
      totalPutOiChange:
          totalPutOiChange,
    );

    final direction =
        _directionFromScore(directionScore);

    final qScore =
        _calculateQScore(
      directionalScore: directionScore,
      calculatedPcr: calculatedPcr,
    );

    return {
      'expiry': expiry,
      'spotPrice': spotPrice,
      'atmStrike': atmStrike,

      'support': {
        'strike': supportStrike,
        'oi': maxPutOi,
      },

      'resistance': {
        'strike': resistanceStrike,
        'oi': maxCallOi,
      },

      'totals': {
        'callOi': totalCallOi,
        'putOi': totalPutOi,
        'callOiChange':
            totalCallOiChange,
        'putOiChange':
            totalPutOiChange,
        'callVolume':
            totalCallVolume,
        'putVolume':
            totalPutVolume,
        'pcr': calculatedPcr,
      },

      'directionScore':
          directionScore,

      'direction':
          direction,

      'qScore':
          qScore,

      'rowsAnalyzed':
          rows.length,
    };
  }

  double _calculateDirectionalScore({
    required double spotPrice,
    required double? supportStrike,
    required double? resistanceStrike,
    required double calculatedPcr,
    required double totalCallOiChange,
    required double totalPutOiChange,
  }) {
    double score = 0;

    // PCR
    if (calculatedPcr >= 1.20) {
      score += 25;
    } else if (calculatedPcr >= 1.00) {
      score += 10;
    } else if (calculatedPcr <= 0.80) {
      score -= 25;
    } else if (calculatedPcr < 1.00) {
      score -= 10;
    }

    // OI change
    if (totalPutOiChange >
        totalCallOiChange) {
      score += 25;
    } else if (totalCallOiChange >
        totalPutOiChange) {
      score -= 25;
    }

    // Position relative to support/resistance
    if (supportStrike != null &&
        resistanceStrike != null) {
      if (spotPrice > resistanceStrike) {
        score += 25;
      } else if (spotPrice < supportStrike) {
        score -= 25;
      }
    }

    // If price is between support and resistance,
    // do not artificially create a directional signal.

    return score.clamp(-100.0, 100.0).toDouble();
  }

  String _directionFromScore(
    double score,
  ) {
    if (score >= 25) {
      return 'BULLISH';
    }

    if (score <= -25) {
      return 'BEARISH';
    }

    return 'NEUTRAL';
  }

  double _calculateQScore({
    required double directionalScore,
    required double calculatedPcr,
  }) {
    // Convert directional score (-100 to +100)
    // into confidence score (0 to 100).
    double score =
        50 + (directionalScore / 2);

    return score
        .clamp(0.0, 100.0)
        .toDouble();
  }

  Map<String, dynamic> _map(
    dynamic value,
  ) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  double _toDouble(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }
}