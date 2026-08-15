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
    required int tradesToday,
    required int maxTradesPerDay,
    required bool liveExecutionEnabled,
    required bool paperTrade,
  }) {
    final blockingReasons = <String>[];

    // LIVE execution is allowed only when explicitly enabled.
    // Paper trading does not require live broker execution.
    if (!paperTrade && !liveExecutionEnabled) {
      blockingReasons.add('Live broker execution is disabled.');
    }

    if (!brokerConnected && !paperTrade) {
      blockingReasons.add('Broker is not connected.');
    }

    if (!marketFeedConnected) {
      blockingReasons.add('Live market feed is not connected.');
    }

    if (!constitutionPassed) {
      blockingReasons.add('Trading Constitution has not passed.');
    }

    if (!strategyPolicyPassed) {
      blockingReasons.add('Strategy policy has not passed.');
    }

    if (maxTradesPerDay > 0 && tradesToday >= maxTradesPerDay) {
      blockingReasons.add(
        'Maximum daily trade limit reached: '
        '$tradesToday/$maxTradesPerDay.',
      );
    }

    return TradeExecutionGuardResult(
      allowed: blockingReasons.isEmpty,
      blockingReasons: blockingReasons,
    );
  }
}
