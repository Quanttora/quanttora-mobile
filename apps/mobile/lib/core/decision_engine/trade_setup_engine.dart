class TradeSetupResult {
  final bool valid;
  final String direction;

  final double entryPrice;
  final double stopLoss;
  final double targetPrice;

  final double riskPerUnit;
  final double rewardPerUnit;
  final double riskRewardRatio;

  final int quantity;
  final double totalRisk;
  final double totalReward;

  final List<String> reasons;

  const TradeSetupResult({
    required this.valid,
    required this.direction,
    required this.entryPrice,
    required this.stopLoss,
    required this.targetPrice,
    required this.riskPerUnit,
    required this.rewardPerUnit,
    required this.riskRewardRatio,
    required this.quantity,
    required this.totalRisk,
    required this.totalReward,
    required this.reasons,
  });
}

class TradeSetupEngine {
  const TradeSetupEngine._();

  static TradeSetupResult calculate({
    required double currentPrice,
    required String direction,
    required double riskRewardRatio,
    required double stopLossPercent,
    required double capital,
    required double riskPercent,
    int? requestedQuantity,
  }) {
    final normalizedDirection = direction.trim().toUpperCase();

    final reasons = <String>[];

    if (currentPrice <= 0) {
      return const TradeSetupResult(
        valid: false,
        direction: '',
        entryPrice: 0,
        stopLoss: 0,
        targetPrice: 0,
        riskPerUnit: 0,
        rewardPerUnit: 0,
        riskRewardRatio: 0,
        quantity: 0,
        totalRisk: 0,
        totalReward: 0,
        reasons: ['Current market price is invalid.'],
      );
    }

    if (riskRewardRatio <= 0) {
      return const TradeSetupResult(
        valid: false,
        direction: '',
        entryPrice: 0,
        stopLoss: 0,
        targetPrice: 0,
        riskPerUnit: 0,
        rewardPerUnit: 0,
        riskRewardRatio: 0,
        quantity: 0,
        totalRisk: 0,
        totalReward: 0,
        reasons: ['Risk : Reward ratio must be greater than zero.'],
      );
    }

    if (stopLossPercent <= 0) {
      return const TradeSetupResult(
        valid: false,
        direction: '',
        entryPrice: 0,
        stopLoss: 0,
        targetPrice: 0,
        riskPerUnit: 0,
        rewardPerUnit: 0,
        riskRewardRatio: 0,
        quantity: 0,
        totalRisk: 0,
        totalReward: 0,
        reasons: ['Stop Loss percentage must be greater than zero.'],
      );
    }

    if (normalizedDirection != 'CALL' && normalizedDirection != 'PUT') {
      return const TradeSetupResult(
        valid: false,
        direction: '',
        entryPrice: 0,
        stopLoss: 0,
        targetPrice: 0,
        riskPerUnit: 0,
        rewardPerUnit: 0,
        riskRewardRatio: 0,
        quantity: 0,
        totalRisk: 0,
        totalReward: 0,
        reasons: ['Trade direction must be CALL or PUT.'],
      );
    }

    final entryPrice = currentPrice;

    final stopDistance = entryPrice * stopLossPercent / 100;

    late final double stopLoss;
    late final double targetPrice;

    if (normalizedDirection == 'CALL') {
      stopLoss = entryPrice - stopDistance;

      final rewardDistance = stopDistance * riskRewardRatio;

      targetPrice = entryPrice + rewardDistance;
    } else {
      stopLoss = entryPrice + stopDistance;

      final rewardDistance = stopDistance * riskRewardRatio;

      targetPrice = entryPrice - rewardDistance;
    }

    final riskPerUnit = (entryPrice - stopLoss).abs();

    final rewardPerUnit = (targetPrice - entryPrice).abs();

    final calculatedRatio = riskPerUnit > 0 ? rewardPerUnit / riskPerUnit : 0.0;

    final allowedRisk = capital > 0 && riskPercent > 0
        ? capital * riskPercent / 100
        : 0.0;

    int quantity;

    if (requestedQuantity != null && requestedQuantity > 0) {
      quantity = requestedQuantity;
    } else if (allowedRisk > 0 && riskPerUnit > 0) {
      quantity = (allowedRisk / riskPerUnit).floor();
    } else {
      quantity = 0;
    }

    final totalRisk = riskPerUnit * quantity;

    final totalReward = rewardPerUnit * quantity;

    reasons.add('Entry is based on the current market price.');

    reasons.add(
      'Stop Loss is ${stopLossPercent.toStringAsFixed(2)}% '
      'from entry.',
    );

    reasons.add(
      'Target uses the configured '
      '1:${riskRewardRatio.toStringAsFixed(2)} '
      'Risk : Reward ratio.',
    );

    if (allowedRisk > 0) {
      reasons.add(
        'Maximum calculated risk is '
        '${allowedRisk.toStringAsFixed(2)}.',
      );
    }

    if (quantity > 0) {
      reasons.add('Calculated quantity is $quantity.');
    } else {
      reasons.add(
        'Quantity could not be calculated from the '
        'available capital and risk settings.',
      );
    }

    return TradeSetupResult(
      valid: stopLoss > 0 && targetPrice > 0 && calculatedRatio > 0,
      direction: normalizedDirection,
      entryPrice: entryPrice,
      stopLoss: stopLoss,
      targetPrice: targetPrice,
      riskPerUnit: riskPerUnit,
      rewardPerUnit: rewardPerUnit,
      riskRewardRatio: calculatedRatio,
      quantity: quantity,
      totalRisk: totalRisk,
      totalReward: totalReward,
      reasons: reasons,
    );
  }
}
