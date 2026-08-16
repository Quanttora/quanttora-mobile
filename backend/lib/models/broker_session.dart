class BrokerSession {
  final String broker;
  final String userId;
  final String userName;
  final String email;

  final String accessToken;
  final String? refreshToken;

  final DateTime connectedAt;

  /// When the current access token expires.
  ///
  /// This is nullable so existing sessions created before
  /// token-expiry tracking was introduced remain compatible.
  final DateTime? accessTokenExpiresAt;

  const BrokerSession({
    required this.broker,
    required this.userId,
    required this.userName,
    required this.email,
    required this.accessToken,
    this.refreshToken,
    required this.connectedAt,
    this.accessTokenExpiresAt,
  });

  /// Returns true when the access token is present and has
  /// not reached its known expiry time.
  bool get hasValidAccessToken {
    if (accessToken.isEmpty) {
      return false;
    }

    final expiry = accessTokenExpiresAt;

    if (expiry == null) {
      return true;
    }

    return DateTime.now().isBefore(expiry);
  }

  /// Returns true when the access token is known to be expired.
  bool get isAccessTokenExpired {
    final expiry = accessTokenExpiresAt;

    if (expiry == null) {
      return false;
    }

    return !DateTime.now().isBefore(expiry);
  }

  Map<String, dynamic> toJson() {
    return {
      'broker': broker,
      'userId': userId,
      'userName': userName,
      'email': email,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'connectedAt': connectedAt.toIso8601String(),
      'accessTokenExpiresAt': accessTokenExpiresAt?.toIso8601String(),
    };
  }

  factory BrokerSession.fromJson(Map<String, dynamic> json) {
    final connectedAtValue = json['connectedAt']?.toString();

    final expiresAtValue = json['accessTokenExpiresAt']?.toString();

    return BrokerSession(
      broker: json['broker']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString(),
      connectedAt: connectedAtValue == null || connectedAtValue.isEmpty
          ? DateTime.now()
          : DateTime.parse(connectedAtValue),
      accessTokenExpiresAt: expiresAtValue == null || expiresAtValue.isEmpty
          ? null
          : DateTime.parse(expiresAtValue),
    );
  }
}
