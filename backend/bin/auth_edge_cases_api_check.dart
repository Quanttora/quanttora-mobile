import 'dart:convert';

import 'package:http/http.dart' as http;

const baseUrl = 'http://localhost:8080';

const testEmail = 'quanttora-real-auth-integration@quanttora.local';
const testPassword = 'RealAuthIntegration#2026';
const testDisplayName = 'Quanttora Real Auth Integration';

Future<void> main() async {
  print('========================================');
  print('QUANTTORA REAL AUTH INTEGRATION TEST');
  print('========================================');

  final client = http.Client();

  try {
    await _cleanupUser(client);

    print('');
    print('1. REGISTER');

    final registerResponse = await client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': testEmail,
        'password': testPassword,
        'displayName': testDisplayName,
      }),
    );

    _expectStatus(registerResponse, 201, 'Registration');

    final registerBody = _decode(registerResponse);
    final registeredUser = registerBody['data']?['user'];

    _expect(
      registeredUser is Map,
      'Registration returned user',
    );

    _expect(
      registeredUser['email'] == testEmail,
      'Registration returned correct email',
    );

    _expect(
      registeredUser['displayName'] == testDisplayName,
      'Registration returned correct display name',
    );

    _expect(
      !registeredUser.containsKey('password'),
      'Password is not exposed',
    );

    final userId = registeredUser['id'];

    print('User ID: $userId');

    print('');
    print('2. LOGIN');

    final loginResponse = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': testEmail,
        'password': testPassword,
      }),
    );

    _expectStatus(loginResponse, 200, 'Login');

    final loginBody = _decode(loginResponse);
    final loginUser = loginBody['data']?['user'];
    final session = loginBody['data']?['session'];

    _expect(loginUser is Map, 'Login returned user');
    _expect(session is Map, 'Login returned session');

    _expect(
      loginUser['id'] == userId,
      'Login returned registered user',
    );

    _expect(
      !loginUser.containsKey('password'),
      'Login does not expose password',
    );

    final token = session['token'];

    _expect(
      token is String && token.isNotEmpty,
      'Login returned a session token',
    );

    final authToken = token as String;

    print('Session token received: true');

    print('');
    print('3. AUTHENTICATED /AUTH/ME');

    final meResponse = await client.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    _expectStatus(meResponse, 200, '/auth/me');

    final meBody = _decode(meResponse);
    final meUser = meBody['data']?['user'];

    _expect(meUser is Map, '/auth/me returned user');

    _expect(
      meUser['id'] == userId,
      '/auth/me resolved correct user',
    );

    _expect(
      meUser['email'] == testEmail,
      '/auth/me returned correct email',
    );

    _expect(
      !meUser.containsKey('password'),
      '/auth/me does not expose password',
    );

    print('');
    print('4. INVALID TOKEN');

    final invalidTokenResponse = await client.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer invalid-token-for-integration-test',
      },
    );

    _expectStatus(
      invalidTokenResponse,
      401,
      'Invalid token rejection',
    );

    print('Invalid token rejected: true');

    print('');
    print('5. LOGOUT');

    final logoutResponse = await client.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    _expectStatus(logoutResponse, 200, 'Logout');

    final logoutBody = _decode(logoutResponse);

    _expect(
      logoutBody['data']?['loggedOut'] == true,
      'Logout confirmed',
    );

    print('Session revoked: true');

    print('');
    print('6. REVOKED TOKEN');

    final revokedResponse = await client.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    _expectStatus(
      revokedResponse,
      401,
      'Revoked token rejection',
    );

    print('Revoked token rejected: true');

    print('');
    print('7. LOGIN AGAIN');

    final secondLoginResponse = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': testEmail,
        'password': testPassword,
      }),
    );

    _expectStatus(secondLoginResponse, 200, 'Second login');

    final secondLoginBody = _decode(secondLoginResponse);
    final secondSession =
        secondLoginBody['data']?['session'];

    _expect(
      secondSession is Map,
      'Second login returned session',
    );

    final secondToken = secondSession['token'];

    _expect(
      secondToken is String && secondToken.isNotEmpty,
      'Second login returned session token',
    );

    _expect(
      secondToken != authToken,
      'Second login created a new session token',
    );

    print('New session created: true');

    print('');
    print('8. SECOND SESSION /AUTH/ME');

    final secondMeResponse = await client.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer $secondToken',
      },
    );

    _expectStatus(
      secondMeResponse,
      200,
      'Second session /auth/me',
    );

    final secondMeBody = _decode(secondMeResponse);
    final secondMeUser = secondMeBody['data']?['user'];

    _expect(
      secondMeUser is Map,
      'Second session resolved user',
    );

    _expect(
      secondMeUser['id'] == userId,
      'Second session resolved correct user',
    );

    print('Second session remains usable: true');

    print('');
    print('9. CLEANUP');

    await client.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: {
        'Authorization': 'Bearer $secondToken',
      },
    );

    await _cleanupUser(client);

    print('Test user cleanup requested');

    print('');
    print('========================================');
    print('REAL AUTH INTEGRATION TEST PASSED');
    print('========================================');
  } catch (e, stackTrace) {
    print('');
    print('========================================');
    print('REAL AUTH INTEGRATION TEST FAILED');
    print('========================================');
    print('ERROR: $e');
    print('');
    print(stackTrace);

    try {
      await _cleanupUser(client);
    } catch (_) {}

    rethrow;
  } finally {
    client.close();
  }
}

Future<void> _cleanupUser(http.Client client) async {
  // Cleanup is intentionally performed directly against the database
  // by the developer after the real HTTP execution.
  //
  // The API itself does not expose a production user-delete endpoint,
  // so the integration test must not introduce one merely for testing.
}

Map<String, dynamic> _decode(http.Response response) {
  final decoded = jsonDecode(response.body);

  if (decoded is! Map<String, dynamic>) {
    throw StateError(
      'Expected JSON object, got ${decoded.runtimeType}.',
    );
  }

  return decoded;
}

void _expectStatus(
  http.Response response,
  int expected,
  String operation,
) {
  if (response.statusCode != expected) {
    throw StateError(
      '$operation returned HTTP ${response.statusCode}, '
      'expected $expected.\nResponse: ${response.body}',
    );
  }

  print('$operation HTTP $expected: true');
}

void _expect(bool condition, String description) {
  if (!condition) {
    throw StateError('FAILED: $description');
  }

  print('$description: true');
}
