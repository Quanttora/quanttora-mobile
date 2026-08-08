class TradeSession {
  // Broker
  String broker;

  // Instrument
  String instrument;

  // Trading Mode
  String tradingMode;

  // Strategy
  String strategy;

  // Risk
  double riskPercent;

  // Risk Reward
  String riskReward;

  // Future
  bool paperTrade;

  TradeSession({
    this.broker = "",
    this.instrument = "",
    this.tradingMode = "",
    this.strategy = "",
    this.riskPercent = 1.0,
    this.riskReward = "1:3",
    this.paperTrade = true,
  });

  TradeSession copyWith({
    String? broker,
    String? instrument,
    String? tradingMode,
    String? strategy,
    double? riskPercent,
    String? riskReward,
    bool? paperTrade,
  }) {
    return TradeSession(
      broker: broker ?? this.broker,
      instrument: instrument ?? this.instrument,
      tradingMode: tradingMode ?? this.tradingMode,
      strategy: strategy ?? this.strategy,
      riskPercent: riskPercent ?? this.riskPercent,
      riskReward: riskReward ?? this.riskReward,
      paperTrade: paperTrade ?? this.paperTrade,
    );
  }
}
