class BrokerResponse<T> {
  final bool success;

  final String message;

  final T? data;

  const BrokerResponse({
    required this.success,
    required this.message,
    this.data,
  });
}
