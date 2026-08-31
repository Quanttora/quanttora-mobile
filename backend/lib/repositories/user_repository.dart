import 'package:backend/database/database.dart';
import 'package:backend/models/user.dart';
import 'package:postgres/postgres.dart';

class UserRepository {
  UserRepository._();

  static const String _selectColumns = '''
    id,
    email,
    password_hash,
    display_name,
    status,
    email_verified_at,
    last_login_at,
    created_at,
    updated_at,
    supabase_user_id
  ''';

  static Future<User?> findById(int id) async {
    final result = await Database.execute(
      Sql.named('''
        SELECT $_selectColumns
        FROM users
        WHERE id = @id
        LIMIT 1
      '''),
      parameters: {'id': id},
    );

    if (result.isEmpty) {
      return null;
    }

    return User.fromRow(result.first);
  }

  static Future<User?> findByEmail(String email) async {
    final normalizedEmail = _normalizeEmail(email);

    final result = await Database.execute(
      Sql.named('''
        SELECT $_selectColumns
        FROM users
        WHERE LOWER(email) = LOWER(@email)
        LIMIT 1
      '''),
      parameters: {'email': normalizedEmail},
    );

    if (result.isEmpty) {
      return null;
    }

    return User.fromRow(result.first);
  }

  static Future<User?> findBySupabaseUserId(String supabaseUserId) async {
    final normalizedId = supabaseUserId.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    final result = await Database.execute(
      Sql.named('''
        SELECT $_selectColumns
        FROM users
        WHERE supabase_user_id = @supabaseUserId
        LIMIT 1
      '''),
      parameters: {'supabaseUserId': normalizedId},
    );

    if (result.isEmpty) {
      return null;
    }

    return User.fromRow(result.first);
  }

  static Future<User> create({
    required String email,
    required String passwordHash,
    required String displayName,
    String? supabaseUserId,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final normalizedDisplayName = displayName.trim();
    final normalizedSupabaseUserId = supabaseUserId?.trim();

    if (normalizedEmail.isEmpty) {
      throw ArgumentError('Email cannot be empty.');
    }

    if (normalizedDisplayName.isEmpty) {
      throw ArgumentError('Display name cannot be empty.');
    }

    final result = await Database.execute(
      Sql.named('''
        INSERT INTO users (
          email,
          password_hash,
          display_name,
          supabase_user_id
        )
        VALUES (
          @email,
          @passwordHash,
          @displayName,
          @supabaseUserId
        )
        RETURNING $_selectColumns
      '''),
      parameters: {
        'email': normalizedEmail,
        'passwordHash': passwordHash,
        'displayName': normalizedDisplayName,
        'supabaseUserId': normalizedSupabaseUserId,
      },
    );

    return User.fromRow(result.first);
  }

  static Future<void> linkSupabaseUser(
    int userId,
    String supabaseUserId,
  ) async {
    final normalizedSupabaseUserId = supabaseUserId.trim();

    if (normalizedSupabaseUserId.isEmpty) {
      throw ArgumentError('Supabase user ID cannot be empty.');
    }

    await Database.execute(
      Sql.named('''
        UPDATE users
        SET
          supabase_user_id = @supabaseUserId,
          updated_at = NOW()
        WHERE id = @userId
          AND (
            supabase_user_id IS NULL
            OR supabase_user_id = @supabaseUserId
          )
      '''),
      parameters: {
        'userId': userId,
        'supabaseUserId': normalizedSupabaseUserId,
      },
    );
  }

  static Future<void> updateLastLogin(int id) async {
    await Database.execute(
      Sql.named('''
        UPDATE users
        SET
          last_login_at = NOW(),
          updated_at = NOW()
        WHERE id = @id
      '''),
      parameters: {'id': id},
    );
  }

  static Future<void> markEmailVerified(int id) async {
    await Database.execute(
      Sql.named('''
        UPDATE users
        SET
          email_verified_at = NOW(),
          updated_at = NOW()
        WHERE id = @id
      '''),
      parameters: {'id': id},
    );
  }

  static String _normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }
}
