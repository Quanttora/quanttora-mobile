import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuanttoraAuthResponse {
  const QuanttoraAuthResponse({this.user, this.session});

  final Map<String, dynamic>? user;
  final QuanttoraAuthSession? session;
}

class QuanttoraAuthSession {
  const QuanttoraAuthSession({required this.token, required this.expiresAt});

  final String token;
  final DateTime expiresAt;
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const String _tokenKey = 'quanttora_auth_token';
  static const String _expiresAtKey = 'quanttora_auth_expires_at';
  static const String _userKey = 'quanttora_auth_user';

  static const Duration _timeout = Duration(seconds: 15);

  final ValueNotifier<bool> _authenticated = ValueNotifier<bool>(false);

  final StreamController<bool> _authStateController =
      StreamController<bool>.broadcast();

  SharedPreferences? _preferences;

  String? _accessToken;
  DateTime? _expiresAt;
  Map<String, dynamic>? _user;

  bool _initialized = false;

  String get _baseUrl {
    final value = dotenv.env['API_BASE_URL']?.trim();

    if (value == null || value.isEmpty) {
      throw StateError('API_BASE_URL is not configured in .env');
    }

    if (value.endsWith('/')) {
      return value.substring(0, value.length - 1);
    }

    return value;
  }

  bool get isAuthenticated {
    if (_accessToken == null || _accessToken!.isEmpty) {
      return false;
    }

    if (_expiresAt != null && !_expiresAt!.isAfter(DateTime.now().toUtc())) {
      return false;
    }

    return true;
  }

  String? get accessToken {
    if (!isAuthenticated) {
      return null;
    }

    return _accessToken;
  }

  DateTime? get expiresAt => _expiresAt;

  Map<String, dynamic>? get currentUser => _user;

  ValueListenable<bool> get authenticationNotifier => _authenticated;

  Stream<bool> get authStateChanges async* {
    await initialize();

    yield isAuthenticated;

    yield* _authStateController.stream;
  }

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _preferences = await SharedPreferences.getInstance();

    _accessToken = _preferences!.getString(_tokenKey);

    final expiresAtValue = _preferences!.getString(_expiresAtKey);

    if (expiresAtValue != null && expiresAtValue.isNotEmpty) {
      _expiresAt = DateTime.tryParse(expiresAtValue)?.toUtc();
    }

    final userValue = _preferences!.getString(_userKey);

    if (userValue != null && userValue.isNotEmpty) {
      try {
        final decoded = jsonDecode(userValue);

        if (decoded is Map) {
          _user = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        _user = null;
      }
    }

    _initialized = true;

    if (!isAuthenticated) {
      await _clearLocalSession(emit: false);
      return;
    }

    _authenticated.value = true;

    try {
      final response = await _request(method: 'GET', path: '/auth/me');

      final data = _extractData(response);
      final user = data['user'];

      if (user is Map) {
        _user = Map<String, dynamic>.from(user);

        await _preferences!.setString(_userKey, jsonEncode(_user));
      }

      _authenticated.value = true;
    } catch (_) {
      await _clearLocalSession();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    await initialize();

    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      throw const AuthException('Email is required.');
    }

    if (password.isEmpty) {
      throw const AuthException('Password is required.');
    }

    try {
      final response = await _request(
        method: 'POST',
        path: '/auth/login',
        body: {'email': normalizedEmail, 'password': password},
      );

      final data = _extractData(response);

      final session = data['session'];

      if (session is! Map) {
        throw const AuthException(
          'Login succeeded but no Quanttora session was returned.',
        );
      }

      final token = session['token']?.toString().trim() ?? '';
      final expiresAtValue = session['expiresAt']?.toString().trim() ?? '';

      if (token.isEmpty || expiresAtValue.isEmpty) {
        throw const AuthException(
          'Login succeeded but the session is invalid.',
        );
      }

      final expiresAt = DateTime.tryParse(expiresAtValue)?.toUtc();

      if (expiresAt == null) {
        throw const AuthException(
          'Login succeeded but the session expiry is invalid.',
        );
      }

      final user = data['user'];

      _accessToken = token;
      _expiresAt = expiresAt;
      _user = user is Map ? Map<String, dynamic>.from(user) : null;

      await _saveLocalSession();

      _authenticated.value = true;
      _authStateController.add(true);
    } on ApiAuthException catch (error) {
      throw AuthException(error.message);
    } on AuthException {
      rethrow;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Quanttora sign-in error: $error');
      }

      throw const AuthException(
        'Unable to sign in. Please check the backend connection.',
      );
    }
  }

  Future<QuanttoraAuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await initialize();

    final normalizedEmail = email.trim().toLowerCase();
    final normalizedName = fullName.trim();

    if (normalizedName.isEmpty) {
      throw const AuthException('Full name is required.');
    }

    if (normalizedEmail.isEmpty) {
      throw const AuthException('Email is required.');
    }

    if (password.isEmpty) {
      throw const AuthException('Password is required.');
    }

    try {
      final response = await _request(
        method: 'POST',
        path: '/auth/register',
        body: {
          'email': normalizedEmail,
          'password': password,
          'displayName': normalizedName,
        },
      );

      final data = _extractData(response);

      final user = data['user'];

      return QuanttoraAuthResponse(
        user: user is Map ? Map<String, dynamic>.from(user) : null,
        session: null,
      );
    } on ApiAuthException catch (error) {
      throw AuthException(error.message);
    } on AuthException {
      rethrow;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Quanttora registration error: $error');
      }

      throw const AuthException(
        'Unable to create your account. Please try again.',
      );
    }
  }

  Future<void> signOut() async {
    final token = _accessToken;

    if (token != null && token.isNotEmpty) {
      try {
        await _request(method: 'POST', path: '/auth/logout', token: token);
      } catch (_) {
        // Local logout must still complete.
      }
    }

    await _clearLocalSession();
  }

  Future<void> resetPassword({required String email}) async {
    throw const AuthException('Password reset is not available yet.');
  }

  Future<Map<String, dynamic>> _request({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final authorizationToken = token ?? _accessToken;

    if (authorizationToken != null && authorizationToken.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${authorizationToken.trim()}';
    }

    late http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: headers).timeout(_timeout);
        break;

      case 'POST':
        response = await http
            .post(
              uri,
              headers: headers,
              body: body == null ? null : jsonEncode(body),
            )
            .timeout(_timeout);
        break;

      default:
        throw StateError('Unsupported HTTP method: $method');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Request failed (${response.statusCode}).';

      if (response.body.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);

          if (decoded is Map) {
            final apiMessage = decoded['message'] ?? decoded['error'];

            if (apiMessage != null && apiMessage.toString().trim().isNotEmpty) {
              message = apiMessage.toString();
            }
          }
        } catch (_) {
          // Keep HTTP status message.
        }
      }

      throw ApiAuthException(statusCode: response.statusCode, message: message);
    }

    if (response.body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw const FormatException('Expected a JSON object from the backend.');
    }

    return Map<String, dynamic>.from(decoded);
  }

  Map<String, dynamic> _extractData(Map<String, dynamic> response) {
    final data = response['data'];

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return response;
  }

  Future<void> _saveLocalSession() async {
    final preferences = _preferences ??= await SharedPreferences.getInstance();

    final token = _accessToken;

    if (token == null || token.isEmpty) {
      return;
    }

    await preferences.setString(_tokenKey, token);

    if (_expiresAt != null) {
      await preferences.setString(
        _expiresAtKey,
        _expiresAt!.toUtc().toIso8601String(),
      );
    }

    if (_user != null) {
      await preferences.setString(_userKey, jsonEncode(_user));
    }
  }

  Future<void> _clearLocalSession({bool emit = true}) async {
    _accessToken = null;
    _expiresAt = null;
    _user = null;

    final preferences = _preferences ??= await SharedPreferences.getInstance();

    await preferences.remove(_tokenKey);
    await preferences.remove(_expiresAtKey);
    await preferences.remove(_userKey);

    _authenticated.value = false;

    if (emit) {
      _authStateController.add(false);
    }
  }

  void dispose() {
    _authStateController.close();
    _authenticated.dispose();
  }
}

class ApiAuthException implements Exception {
  const ApiAuthException({required this.statusCode, required this.message});

  final int statusCode;
  final String message;

  @override
  String toString() {
    return 'ApiAuthException($statusCode): $message';
  }
}
