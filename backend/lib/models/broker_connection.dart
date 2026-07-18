class BrokerConnection {
  final String broker;
  final String userId;
  final String userName;
  final String email;

  // These stay on the backend only
  final String accessToken;
  final String extendedToken;

  const BrokerConnection({
    required this.broker,
    required this.userId,
    required this.userName,
    required this.email,
    required this.accessToken,
    required this.extendedToken,
  });

  Map<String, dynamic> toPublicJson() {
    return {
      'success': true,
      'broker': broker,
      'status': 'CONNECTED',
      'user': {
        'id': userId,
        'name': userName,
        'email': email,
      }
    };
  }
}