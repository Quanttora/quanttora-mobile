class Currency {
  final String pair;

  final double value;

  final double changePercent;

  const Currency({
    required this.pair,
    required this.value,
    required this.changePercent,
  });
}