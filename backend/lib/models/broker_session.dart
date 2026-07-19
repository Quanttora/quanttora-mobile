class BrokerSession {
  final String broker;
  final String userId;
  final String userName;
  final String email;
  final String accessToken;
  final DateTime connectedAt;

  const BrokerSession({
    required this.broker,
    required this.userId,
    required this.userName,
    required this.email,
    required this.accessToken,
    required this.connectedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'broker': broker,
      'userId': userId,
      'userName': userName,
      'email': email,
      'accessToken': accessToken,
      'connectedAt': connectedAt.toIso8601String(),
    };
  }

  factory BrokerSession.fromJson(Map<String, dynamic> json) {
    return BrokerSession(
      broker: json['broker'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      accessToken: json['accessToken'] ?? '',
      connectedAt: DateTime.parse(
        json['connectedAt'],
      ),
    );
  }
}