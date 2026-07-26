class AnalysisInput {
  final String symbol;
  final String optionType;
  final String timeframe;

  final double currentPrice;

  final double ema20;
  final double ema50;

  final double vwap;

  final double rsi;

  final double volume;
  final double averageVolume;

  final double atr;

  final double entryPrice;
  final double stopLoss;
  final double target;

  final bool constitutionPassed;

  const AnalysisInput({
    required this.symbol,
    required this.optionType,
    required this.timeframe,
    required this.currentPrice,
    required this.ema20,
    required this.ema50,
    required this.vwap,
    required this.rsi,
    required this.volume,
    required this.averageVolume,
    required this.atr,
    required this.entryPrice,
    required this.stopLoss,
    required this.target,
    required this.constitutionPassed,
  });
}