class BrokerException implements Exception {
  final String message;

  const BrokerException(this.message);

  @override
  String toString() => message;
}
