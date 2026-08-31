import 'dart:convert';

import 'package:backend/core/config/app_config.dart';
import 'package:backend/models/user.dart';
import 'package:backend/repositories/user_repository.dart';
import 'package:http/http.dart' as http;

class SupabaseAuthService {
  SupabaseAuthService._();

  static const Duration _timeout = Duration(seconds: 10);

  static Future<User?> authenticateAccessToken(String accessToken) async {
    final token = accessToken.trim();

    if (token.isEmpty) {
      print('SUPABASE AUTH: Empty access token.');
      return null;
    }

    final supabaseUrl = AppConfig.supabaseUrl.trim();
    final publishableKey = AppConfig.supabasePublishableKey.trim();

    if (supabaseUrl.isEmpty || publishableKey.isEmpty) {
      print('SUPABASE AUTH: Supabase configuration is incomplete.');
      return null;
    }

    final baseUrl = supabaseUrl.endsWith('/')
        ? supabaseUrl.substring(0, supabaseUrl.length - 1)
        : supabaseUrl;

    final uri = Uri.parse('$baseUrl/auth/v1/user');

    print('SUPABASE AUTH: Verifying access token...');
    print('SUPABASE AUTH: URL configured: $baseUrl');

    final response = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            'apikey': publishableKey,
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(_timeout);

    print('SUPABASE AUTH: /auth/v1/user status = ${response.statusCode}');

    if (response.statusCode != 200) {
      print(
        'SUPABASE AUTH: Verification failed. '
        'Response: ${response.body}',
      );
      return null;
    }

    if (response.body.trim().isEmpty) {
      print('SUPABASE AUTH: Empty Supabase user response.');
      return null;
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      print('SUPABASE AUTH: Invalid Supabase user response format.');
      return null;
    }

    final supabaseUserId = decoded['id']?.toString().trim() ?? '';
    final email = decoded['email']?.toString().trim().toLowerCase() ?? '';

    print('SUPABASE AUTH: Supabase user ID: $supabaseUserId');
    print('SUPABASE AUTH: Supabase email: $email');

    if (supabaseUserId.isEmpty) {
      print('SUPABASE AUTH: Supabase user has no ID.');
      return null;
    }

    if (email.isEmpty) {
      print('SUPABASE AUTH: Supabase user has no email.');
      return null;
    }

    // First resolve the Quanttora account by Supabase identity.
    var user = await UserRepository.findBySupabaseUserId(supabaseUserId);

    if (user != null) {
      if (!user.isActive) {
        print(
          'SUPABASE AUTH: Quanttora user is inactive. '
          'User ID: ${user.id}',
        );
        return null;
      }

      print(
        'SUPABASE AUTH: Quanttora user authenticated by Supabase ID. '
        'User ID: ${user.id}',
      );

      return user;
    }

    // For an existing account, fall back to email once and establish
    // the permanent Supabase identity mapping.
    user = await UserRepository.findByEmail(email);

    if (user == null) {
      print('SUPABASE AUTH: No Quanttora user found for email: $email');
      return null;
    }

    if (!user.isActive) {
      print(
        'SUPABASE AUTH: Quanttora user is inactive. '
        'User ID: ${user.id}',
      );
      return null;
    }

    final existingSupabaseIdentity = await UserRepository.findBySupabaseUserId(
      supabaseUserId,
    );

    if (existingSupabaseIdentity != null &&
        existingSupabaseIdentity.id != user.id) {
      print(
        'SUPABASE AUTH: Supabase identity is already linked '
        'to another Quanttora user.',
      );
      return null;
    }

    await UserRepository.linkSupabaseUser(user.id, supabaseUserId);

    user = await UserRepository.findById(user.id);

    if (user == null || !user.isActive) {
      print('SUPABASE AUTH: Failed to reload linked Quanttora user.');
      return null;
    }

    print(
      'SUPABASE AUTH: Supabase identity linked successfully. '
      'User ID: ${user.id}',
    );

    return user;
  }
}
