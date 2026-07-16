class BrokerAccount {
  final String broker;

  final String clientId;

  final String clientName;

  final double availableMargin;

  final double usedMargin;

  final double openingBalance;

  final bool connected;

  const BrokerAccount({
    required this.broker,
    required this.clientId,
    required this.clientName,
    required this.availableMargin,
    required this.usedMargin,
    required this.openingBalance,
    required this.connected,
  });
}