class RiskGuardRequest {
  final double capital;
  final double entryPrice;
  final double stopLossPrice;
  final double targetPrice;
  final int quantity;

  final double maxRiskPerTrade;
  final double maxDailyLoss;
  final int maxTradesPerDay;
  final int tradesTakenToday;
  final double dailyLossToday;
  final double minimumRiskReward;

  const RiskGuardRequest({
    required this.capital,
    required this.entryPrice,
    required this.stopLossPrice,
    required this.targetPrice,
    required this.quantity,
    required this.maxRiskPerTrade,
    required this.maxDailyLoss,
    required this.maxTradesPerDay,
    required this.tradesTakenToday,
    required this.dailyLossToday,
    required this.minimumRiskReward,
  });
}

class RiskGuardResult {
  final bool allowed;
  final String status;
  final List<String> passedRules;
  final List<String> blockedRules;

  final double riskAmount;
  final double potentialProfit;
  final double riskReward;
  final double riskPercent;
  final double remainingDailyLossCapacity;
  final int remainingTrades;

  const RiskGuardResult({
    required this.allowed,
    required this.status,
    required this.passedRules,
    required this.blockedRules,
    required this.riskAmount,
    required this.potentialProfit,
    required this.riskReward,
    required this.riskPercent,
    required this.remainingDailyLossCapacity,
    required this.remainingTrades,
  });

  Map<String, dynamic> toJson() {
    return {
      'allowed': allowed,
      'status': status,
      'passedRules': passedRules,
      'blockedRules': blockedRules,
      'riskAmount': riskAmount,
      'potentialProfit': potentialProfit,
      'riskReward': riskReward,
      'riskPercent': riskPercent,
      'remainingDailyLossCapacity':
          remainingDailyLossCapacity,
      'remainingTrades': remainingTrades,
    };
  }
}

class RiskGuardService {
  RiskGuardResult evaluate(
    RiskGuardRequest request,
  ) {
    final passedRules = <String>[];
    final blockedRules = <String>[];

    if (request.capital <= 0) {
      return _blocked(
        'Trading capital must be greater than zero.',
        passedRules,
        blockedRules,
      );
    }

    if (request.entryPrice <= 0 ||
        request.stopLossPrice <= 0 ||
        request.targetPrice <= 0) {
      return _blocked(
        'Entry, stop-loss and target prices must be greater than zero.',
        passedRules,
        blockedRules,
      );
    }

    if (request.quantity <= 0) {
      return _blocked(
        'Quantity must be greater than zero.',
        passedRules,
        blockedRules,
      );
    }

    final isLong =
        request.targetPrice > request.entryPrice;

    final stopDistance = isLong
        ? request.entryPrice -
            request.stopLossPrice
        : request.stopLossPrice -
            request.entryPrice;

    final targetDistance = isLong
        ? request.targetPrice -
            request.entryPrice
        : request.entryPrice -
            request.targetPrice;

    if (stopDistance <= 0) {
      blockedRules.add(
        isLong
            ? 'For a long trade, stop-loss must be below entry.'
            : 'For a short trade, stop-loss must be above entry.',
      );
    } else {
      passedRules.add(
        'Stop-loss is positioned correctly.',
      );
    }

    if (targetDistance <= 0) {
      blockedRules.add(
        isLong
            ? 'For a long trade, target must be above entry.'
            : 'For a short trade, target must be below entry.',
      );
    } else {
      passedRules.add(
        'Target is positioned correctly.',
      );
    }

    final riskAmount =
        stopDistance * request.quantity;

    final potentialProfit =
        targetDistance * request.quantity;

    final riskReward =
        riskAmount > 0
            ? potentialProfit / riskAmount
            : 0.0;

    final riskPercent =
        (riskAmount / request.capital) * 100;

    final remainingDailyLossCapacity =
        request.maxDailyLoss -
        request.dailyLossToday;

    final remainingTrades =
        request.maxTradesPerDay -
        request.tradesTakenToday;

    if (riskAmount <=
        request.maxRiskPerTrade) {
      passedRules.add(
        'Risk is within the maximum per-trade limit.',
      );
    } else {
      blockedRules.add(
        'Risk exceeds the maximum per-trade limit.',
      );
    }

    if (riskAmount <=
        remainingDailyLossCapacity) {
      passedRules.add(
        'Risk fits within the remaining daily loss capacity.',
      );
    } else {
      blockedRules.add(
        'Risk exceeds the remaining daily loss capacity.',
      );
    }

    if (remainingTrades > 0) {
      passedRules.add(
        'Daily trade limit is available.',
      );
    } else {
      blockedRules.add(
        'Daily trade limit has been reached.',
      );
    }

    if (riskReward >=
        request.minimumRiskReward) {
      passedRules.add(
        'Risk-to-reward requirement is satisfied.',
      );
    } else {
      blockedRules.add(
        'Risk-to-reward is below the minimum requirement.',
      );
    }

    final allowed =
        blockedRules.isEmpty;

    return RiskGuardResult(
      allowed: allowed,
      status:
          allowed ? 'allowed' : 'blocked',
      passedRules: passedRules,
      blockedRules: blockedRules,
      riskAmount: _round(riskAmount),
      potentialProfit:
          _round(potentialProfit),
      riskReward: _round(riskReward),
      riskPercent: _round(riskPercent),
      remainingDailyLossCapacity:
          _round(
        remainingDailyLossCapacity,
      ),
      remainingTrades:
          remainingTrades < 0
              ? 0
              : remainingTrades,
    );
  }

  RiskGuardResult _blocked(
    String reason,
    List<String> passedRules,
    List<String> blockedRules,
  ) {
    blockedRules.add(reason);

    return RiskGuardResult(
      allowed: false,
      status: 'blocked',
      passedRules: passedRules,
      blockedRules: blockedRules,
      riskAmount: 0,
      potentialProfit: 0,
      riskReward: 0,
      riskPercent: 0,
      remainingDailyLossCapacity: 0,
      remainingTrades: 0,
    );
  }

  double _round(
    double value,
  ) {
    return double.parse(
      value.toStringAsFixed(2),
    );
  }
}