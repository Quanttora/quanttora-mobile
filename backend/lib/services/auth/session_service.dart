import 'dart:convert';
import 'dart:math';

import 'package:backend/repositories/auth/session_repository.dart';
import 'package:cryptography/cryptography.dart';

class SessionService {
  SessionService._();

  static const Duration sessionLifetime = Duration(days: 30);

  static final Random _random = Random.secure();
  static final Sha256 _sha256 = Sha256();

  static String generateToken() {
    final bytes = List<int>.generate(
      32,
      (_) => _random.nextInt(256),
    );

    return base64UrlEncode(bytes);
  }

  static Future<String> hashToken(String token) async {
    final tokenBytes = utf8.encode(token);
    final digest = await _sha256.hash(tokenBytes);

    return base64UrlEncode(digest.bytes);
  }

  static Future<SessionWithToken> createSession({
    required int userId,
  }) async {
    final token = generateToken();
    final tokenHash = await hashToken(token);

    final expiresAt =
        DateTime.now().toUtc().add(sessionLifetime);

    final session = await SessionRepository.create(
      userId: userId,
      tokenHash: tokenHash,
      expiresAt: expiresAt,
    );

    return SessionWithToken(
      session: session,
      token: token,
    );
  }

  static Future<SessionRecord?> validateToken(
    String token,
  ) async {
    if (token.isEmpty) {
      return null;
    }

    final tokenHash = await hashToken(token);

    final session =
        await SessionRepository.findActiveByTokenHash(
      tokenHash,
    );

    if (session == null) {
      return null;
    }

    await SessionRepository.updateLastUsed(session.id);

    return session;
  }

  static Future<void> revokeToken(String token) async {
    if (token.isEmpty) {
      return;
    }

    final tokenHash = await hashToken(token);

    final session =
        await SessionRepository.findActiveByTokenHash(
      tokenHash,
    );

    if (session == null) {
      return;
    }

    await SessionRepository.revoke(session.id);
  }

  static Future<void> revokeAllSessions(int userId) async {
    await SessionRepository.revokeAllForUser(userId);
  }
}

class SessionWithToken extends SessionRecord {
  SessionWithToken({
    required SessionRecord session,
    required this.token,
  }) : super(
          id: session.id,
          userId: session.userId,
          tokenHash: session.tokenHash,
          expiresAt: session.expiresAt,
          revokedAt: session.revokedAt,
          lastUsedAt: session.lastUsedAt,
          createdAt: session.createdAt,
        );

  final String token;
}