class TradeExecutionGuardResult {
  final bool allowed;
  final List<String> blockingReasons;

  const TradeExecutionGuardResult({
    required this.allowed,
    required this.blockingReasons,
  });
}

class TradeExecutionGuard {
  const TradeExecutionGuard();

  TradeExecutionGuardResult evaluate({
    required bool brokerConnected,
    required bool marketFeedConnected,
    required bool constitutionPassed,
    required bool strategyPolicyPassed,
    required int aiConfidence,
    required int minimumAiScore,
    required int tradesToday,
    required int maxTradesPerDay,
    required double riskReward,
    required double minimumRiskReward,
    required bool liveExecutionEnabled,
    required bool paperTrade,
    required bool explicitConfirmation,
  }) {
    final blockingReasons = <String>[];

    // ------------------------------------------------------------
    // LIVE EXECUTION
    // ------------------------------------------------------------

    if (!paperTrade && !liveExecutionEnabled) {
      blockingReasons.add('Live broker execution is disabled.');
    }

    if (!paperTrade && !brokerConnected) {
      blockingReasons.add('Broker is not connected.');
    }

    // ------------------------------------------------------------
    // MARKET DATA
    // ------------------------------------------------------------

    if (!marketFeedConnected) {
      blockingReasons.add('Live market feed is not connected.');
    }

    // ------------------------------------------------------------
    // TRADING CONSTITUTION
    // ------------------------------------------------------------

    if (!constitutionPassed) {
      blockingReasons.add('Trading Constitution has not passed.');
    }

    // ------------------------------------------------------------
    // STRATEGY POLICY
    // ------------------------------------------------------------

    if (!strategyPolicyPassed) {
      blockingReasons.add('Strategy policy has not passed.');
    }

    // ------------------------------------------------------------
    // AI CONFIDENCE
    // ------------------------------------------------------------

    if (aiConfidence < minimumAiScore) {
      blockingReasons.add(
        'AI confidence is below the required minimum: '
        '$aiConfidence/$minimumAiScore.',
      );
    }

    // ------------------------------------------------------------
    // DAILY TRADE LIMIT
    // ------------------------------------------------------------

    if (maxTradesPerDay > 0 && tradesToday >= maxTradesPerDay) {
      blockingReasons.add(
        'Maximum daily trade limit reached: '
        '$tradesToday/$maxTradesPerDay.',
      );
    }

    // ------------------------------------------------------------
    // RISK / REWARD
    // ------------------------------------------------------------

    if (riskReward < minimumRiskReward) {
      blockingReasons.add(
        'Risk/reward is below the required minimum: '
        '${riskReward.toStringAsFixed(2)}/'
        '${minimumRiskReward.toStringAsFixed(2)}.',
      );
    }

    // ------------------------------------------------------------
    // EXPLICIT TRADER CONFIRMATION
    // ------------------------------------------------------------

    if (!paperTrade && !explicitConfirmation) {
      blockingReasons.add(
        'Explicit trader confirmation is required '
        'before live execution.',
      );
    }

    return TradeExecutionGuardResult(
      allowed: blockingReasons.isEmpty,
      blockingReasons: blockingReasons,
    );
  }
}
