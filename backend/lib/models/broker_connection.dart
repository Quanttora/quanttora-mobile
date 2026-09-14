class BrokerConnection {
  final String broker;
  final String userId;
  final String userName;
  final String email;

  // These stay on the backend only.
  final String accessToken;
  final String extendedToken;
  final String refreshToken;
  final DateTime? accessTokenExpiresAt;

  const BrokerConnection({
    required this.broker,
    required this.userId,
    required this.userName,
    required this.email,
    required this.accessToken,
    required this.extendedToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
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