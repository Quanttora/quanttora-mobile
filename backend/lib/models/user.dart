class User {
  const User({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.displayName,
    required this.status,
    this.emailVerifiedAt,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String email;
  final String passwordHash;
  final String displayName;
  final String status;
  final DateTime? emailVerifiedAt;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => status == 'active';

  factory User.fromRow(List<Object?> row) {
    return User(
      id: row[0] as int,
      email: row[1] as String,
      passwordHash: row[2] as String,
      displayName: row[3] as String,
      status: row[4] as String,
      emailVerifiedAt: row[5] as DateTime?,
      lastLoginAt: row[6] as DateTime?,
      createdAt: row[7] as DateTime,
      updatedAt: row[8] as DateTime,
    );
  }

  Map<String, dynamic> toPublicMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'status': status,
      'emailVerifiedAt': emailVerifiedAt?.toUtc().toIso8601String(),
      'lastLoginAt': lastLoginAt?.toUtc().toIso8601String(),
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }
}