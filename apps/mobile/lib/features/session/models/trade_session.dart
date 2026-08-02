class TradeSession {
  // Broker
  final String broker;

  // Instrument
  final String instrument;

  // Trading Mode
  final String tradingMode;

  // Selected Strategy
  final String strategyId;
  final String strategy;

  // Strategy Configuration
  final String strategyTimeframe;
  final List<String> strategyInstruments;
  final int strategyMinimumAiScore;
  final double strategyRiskRewardRatio;
  final int strategyMaxTradesPerDay;
  final bool strategyAvoidNews;
  final bool strategyAvoidSideways;
  final bool strategyAvoidLowVolume;

  // Risk
  final double riskPercent;

  // Risk Reward
  final String riskReward;

  // Future
  final bool paperTrade;

  TradeSession({
    this.broker = '',
    this.instrument = '',
    this.tradingMode = '',
    this.strategyId = '',
    this.strategy = '',
    this.strategyTimeframe = '',
    this.strategyInstruments = const [],
    this.strategyMinimumAiScore = 0,
    this.strategyRiskRewardRatio = 0,
    this.strategyMaxTradesPerDay = 0,
    this.strategyAvoidNews = false,
    this.strategyAvoidSideways = false,
    this.strategyAvoidLowVolume = false,
    this.riskPercent = 1.0,
    this.riskReward = '1:3',
    this.paperTrade = true,
  });

  TradeSession copyWith({
    String? broker,
    String? instrument,
    String? tradingMode,
    String? strategyId,
    String? strategy,
    String? strategyTimeframe,
    List<String>? strategyInstruments,
    int? strategyMinimumAiScore,
    double? strategyRiskRewardRatio,
    int? strategyMaxTradesPerDay,
    bool? strategyAvoidNews,
    bool? strategyAvoidSideways,
    bool? strategyAvoidLowVolume,
    double? riskPercent,
    String? riskReward,
    bool? paperTrade,
  }) {
    return TradeSession(
      broker: broker ?? this.broker,
      instrument: instrument ?? this.instrument,
      tradingMode: tradingMode ?? this.tradingMode,
      strategyId: strategyId ?? this.strategyId,
      strategy: strategy ?? this.strategy,
      strategyTimeframe:
          strategyTimeframe ?? this.strategyTimeframe,
      strategyInstruments:
          strategyInstruments ?? this.strategyInstruments,
      strategyMinimumAiScore:
          strategyMinimumAiScore ?? this.strategyMinimumAiScore,
      strategyRiskRewardRatio:
          strategyRiskRewardRatio ?? this.strategyRiskRewardRatio,
      strategyMaxTradesPerDay:
          strategyMaxTradesPerDay ?? this.strategyMaxTradesPerDay,
      strategyAvoidNews:
          strategyAvoidNews ?? this.strategyAvoidNews,
      strategyAvoidSideways:
          strategyAvoidSideways ?? this.strategyAvoidSideways,
      strategyAvoidLowVolume:
          strategyAvoidLowVolume ?? this.strategyAvoidLowVolume,
      riskPercent: riskPercent ?? this.riskPercent,
      riskReward: riskReward ?? this.riskReward,
      paperTrade: paperTrade ?? this.paperTrade,
    );
  }
}