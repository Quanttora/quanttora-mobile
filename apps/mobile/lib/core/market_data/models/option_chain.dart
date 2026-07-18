class OptionChain {
  final double pcr;

  final double maxCallOI;

  final double maxPutOI;

  final double callVolume;

  final double putVolume;

  const OptionChain({
    required this.pcr,
    required this.maxCallOI,
    required this.maxPutOI,
    required this.callVolume,
    required this.putVolume,
  });
}