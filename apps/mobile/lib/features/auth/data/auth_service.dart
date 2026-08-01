import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Session? get currentSession => _client.auth.currentSession;

  Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedName = fullName.trim();

    if (normalizedName.isEmpty) {
      throw const AuthException(
        'Full name is required.',
      );
    }

    return _client.auth.signUp(
      email: normalizedEmail,
      password: password,
      data: {
        'full_name': normalizedName,
      },
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }

  Future<void> resetPassword({
    required String email,
  }) {
    return _client.auth.resetPasswordForEmail(
      email.trim().toLowerCase(),
    );
  }
}