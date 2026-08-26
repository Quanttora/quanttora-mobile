import 'package:backend/database/database.dart';
import 'package:postgres/postgres.dart';

class SessionRecord {
  const SessionRecord({
    required this.id,
    required this.userId,
    required this.tokenHash,
    required this.expiresAt,
    required this.revokedAt,
    required this.lastUsedAt,
    required this.createdAt,
  });

  final int id;
  final int userId;
  final String tokenHash;
  final DateTime expiresAt;
  final DateTime? revokedAt;
  final DateTime? lastUsedAt;
  final DateTime createdAt;

  bool get isRevoked => revokedAt != null;

  bool get isExpired => !expiresAt.isAfter(DateTime.now().toUtc());

  bool get isActive => !isRevoked && !isExpired;

  factory SessionRecord.fromRow(List<Object?> row) {
    return SessionRecord(
      id: row[0] as int,
      userId: row[1] as int,
      tokenHash: row[2] as String,
      expiresAt: row[3] as DateTime,
      revokedAt: row[4] as DateTime?,
      lastUsedAt: row[5] as DateTime?,
      createdAt: row[6] as DateTime,
    );
  }
}

class SessionRepository {
  SessionRepository._();

  static const String _selectColumns = '''
    id,
    user_id,
    token_hash,
    expires_at,
    revoked_at,
    last_used_at,
    created_at
  ''';

  static Future<SessionRecord> create({
    required int userId,
    required String tokenHash,
    required DateTime expiresAt,
  }) async {
    final result = await Database.execute(
      Sql.named('''
        INSERT INTO user_sessions (
          user_id,
          token_hash,
          expires_at
        )
        VALUES (
          @userId,
          @tokenHash,
          @expiresAt
        )
        RETURNING $_selectColumns
      '''),
      parameters: {
        'userId': userId,
        'tokenHash': tokenHash,
        'expiresAt': expiresAt.toUtc(),
      },
    );

    return SessionRecord.fromRow(result.first);
  }

  static Future<SessionRecord?> findActiveByTokenHash(
    String tokenHash,
  ) async {
    final result = await Database.execute(
      Sql.named('''
        SELECT $_selectColumns
        FROM user_sessions
        WHERE token_hash = @tokenHash
          AND revoked_at IS NULL
          AND expires_at > NOW()
        LIMIT 1
      '''),
      parameters: {
        'tokenHash': tokenHash,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    return SessionRecord.fromRow(result.first);
  }

  static Future<void> updateLastUsed(int sessionId) async {
    await Database.execute(
      Sql.named('''
        UPDATE user_sessions
        SET last_used_at = NOW()
        WHERE id = @sessionId
          AND revoked_at IS NULL
          AND expires_at > NOW()
      '''),
      parameters: {
        'sessionId': sessionId,
      },
    );
  }

  static Future<void> revoke(int sessionId) async {
    await Database.execute(
      Sql.named('''
        UPDATE user_sessions
        SET revoked_at = NOW()
        WHERE id = @sessionId
          AND revoked_at IS NULL
      '''),
      parameters: {
        'sessionId': sessionId,
      },
    );
  }

  static Future<void> revokeAllForUser(int userId) async {
    await Database.execute(
      Sql.named('''
        UPDATE user_sessions
        SET revoked_at = NOW()
        WHERE user_id = @userId
          AND revoked_at IS NULL
      '''),
      parameters: {
        'userId': userId,
      },
    );
  }
}