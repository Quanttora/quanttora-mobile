class OptionChain {
  final double pcr;

  final double maxCallOI;

  final double maxPutOI;

  final double callVolume;

  final double putVolume;

  final double spotPrice;

  final double atmStrike;

  final double supportStrike;

  final double supportOI;

  final double resistanceStrike;

  final double resistanceOI;

  final double callOI;

  final double putOI;

  final double callOIChange;

  final double putOIChange;

  final String direction;

  final double directionScore;

  final double qScore;

  final String expiry;

  final int rowsAnalyzed;

  const OptionChain({
    required this.pcr,
    required this.maxCallOI,
    required this.maxPutOI,
    required this.callVolume,
    required this.putVolume,
    this.spotPrice = 0,
    this.atmStrike = 0,
    this.supportStrike = 0,
    this.supportOI = 0,
    this.resistanceStrike = 0,
    this.resistanceOI = 0,
    this.callOI = 0,
    this.putOI = 0,
    this.callOIChange = 0,
    this.putOIChange = 0,
    this.direction = 'NEUTRAL',
    this.directionScore = 0,
    this.qScore = 0,
    this.expiry = '',
    this.rowsAnalyzed = 0,
  });
}