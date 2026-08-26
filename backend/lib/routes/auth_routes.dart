import 'dart:convert';
import 'dart:io';

import 'package:backend/api/api_response.dart';
import 'package:backend/integrations/upstox/upstox_auth_service.dart';
import 'package:backend/middleware/auth_middleware.dart';
import 'package:backend/models/broker_connection.dart';
import 'package:backend/models/broker_session.dart';
import 'package:backend/repositories/user_repository.dart';
import 'package:backend/services/auth/auth_api_service.dart';
import 'package:backend/services/auth/authentication_service.dart';
import 'package:backend/services/broker_connection_repository.dart';
import 'package:backend/services/broker_service.dart';
import 'package:backend/services/upstox_market_feed.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class AuthRoutes {
  final UpstoxAuthService _upstox = UpstoxAuthService();

  final BrokerConnectionRepository _repository =
      BrokerConnectionRepository();

  final BrokerService _brokerService = BrokerService.instance;

  final UpstoxMarketFeed _marketFeed = UpstoxMarketFeed.instance;

  static const List<String> _marketInstruments = [
    'NSE_INDEX|Nifty 50',
    'NSE_INDEX|Nifty Bank',
    'BSE_INDEX|SENSEX',
    'NSE_INDEX|India VIX',
    'NSE_INDEX|Nifty Auto',
    'NSE_INDEX|Nifty FMCG',
    'NSE_INDEX|Nifty IT',
    'NSE_INDEX|Nifty Metal',
    'NSE_INDEX|Nifty Pharma',
    'NSE_INDEX|Nifty PSU Bank',
    'NSE_INDEX|Nifty Realty',
    'NSE_EQ|INE002A01018',
    'NSE_EQ|INE467B01029',
    'NSE_EQ|INE040A01034',
    'NSE_EQ|INE009A01021',
    'NSE_EQ|INE090A01021',
    'NSE_EQ|INE062A01020',
    'NSE_EQ|INE397D01024',
    'NSE_EQ|INE154A01025',
  ];

  Router get router {
    final router = Router();

    router.post('/register', _register);

    router.post('/login', _login);

    router.post('/logout', _logout);

    router.get(
      '/me',
      AuthMiddleware.requireAuthentication()(
        _me,
      ),
    );

    router.get('/upstox/login', (Request request) {
      return Response.found(_upstox.getLoginUrl());
    });

    router.get('/upstox/callback', (Request request) async {
      final code = request.requestedUri.queryParameters['code'];

      if (code == null || code.isEmpty) {
        print('');
        print('==============================');
        print('UPSTOX CALLBACK ERROR');
        print('Authorization code missing.');
        print('==============================');
        print('');

        return Response(
          HttpStatus.badRequest,
          body: 'Authorization Code Missing',
        );
      }

      try {
        print('');
        print('==============================');
        print('UPSTOX CALLBACK RECEIVED');
        print('Authorization code received.');
        print('Exchanging code for access token...');
        print('==============================');
        print('');

        final token = await _upstox.exchangeCode(code: code);

        final accessToken = token['access_token']?.toString() ?? '';

        if (accessToken.isEmpty) {
          throw Exception('Upstox access token was not returned.');
        }

        print('UPSTOX TOKEN EXCHANGE SUCCESSFUL');

        final refreshToken = token['refresh_token']?.toString();

        final profileResponse = await http
            .get(
              Uri.parse('https://api.upstox.com/v2/user/profile'),
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $accessToken',
              },
            )
            .timeout(const Duration(seconds: 15));

        print(
          'UPSTOX PROFILE STATUS: '
          '${profileResponse.statusCode}',
        );

        if (profileResponse.statusCode != 200) {
          throw Exception(
            'Unable to fetch Upstox profile. '
            'HTTP ${profileResponse.statusCode}: '
            '${profileResponse.body}',
          );
        }

        final decodedProfile = jsonDecode(profileResponse.body);

        if (decodedProfile is! Map) {
          throw Exception('Invalid Upstox profile response.');
        }

        final profileData = decodedProfile['data'];

        if (profileData is! Map) {
          throw Exception('Invalid Upstox profile data.');
        }

        final userId = profileData['user_id']?.toString() ?? '';

        final userName = profileData['user_name']?.toString() ?? '';

        final email = profileData['email']?.toString() ?? '';

        if (userId.isEmpty) {
          throw Exception('Upstox user ID was not returned.');
        }

        final accessTokenExpiresAt =
            _extractAccessTokenExpiry(accessToken);

        final connection = BrokerConnection(
          broker: 'Upstox',
          userId: userId,
          userName: userName,
          email: email,
          accessToken: accessToken,
          extendedToken: token['extended_token']?.toString() ?? '',
        );

        _repository.save(connection);

        final session = BrokerSession(
          broker: connection.broker,
          userId: connection.userId,
          userName: connection.userName,
          email: connection.email,
          accessToken: accessToken,
          refreshToken: refreshToken,
          connectedAt: DateTime.now(),
          accessTokenExpiresAt: accessTokenExpiresAt,
        );

        _brokerService.connect(session);

        print('BROKER SESSION CONNECTED');

        await _marketFeed.connect();

        await _marketFeed.subscribeMany(_marketInstruments);

        print('');
        print('==============================');
        print('UPSTOX CONNECTED');
        print('USER: ${connection.userName}');
        print('EMAIL: ${connection.email}');
        print(
          'MARKET INSTRUMENTS SUBSCRIBED: '
          '${_marketInstruments.length}',
        );

        if (accessTokenExpiresAt != null) {
          print(
            'ACCESS TOKEN EXPIRY: '
            '$accessTokenExpiresAt',
          );
        }

        print('==============================');
        print('');

        return Response.found(
          'http://localhost:3000/broker-connected',
        );
      } catch (e, stackTrace) {
        print('');
        print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        print('UPSTOX CONNECTION FAILED');
        print('ERROR: $e');
        print('STACK TRACE:');
        print(stackTrace);
        print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        print('');

        return Response.internalServerError(
          body:
              'Upstox connection failed. '
              'Check backend terminal for the exact error.',
        );
      }
    });

    return router;
  }

  Future<Response> _register(Request request) async {
    final body = await ApiResponse.readJsonBody(request);

    if (body == null) {
      return ApiResponse.error(
        statusCode: HttpStatus.badRequest,
        code: 'INVALID_JSON',
        message: 'Request body must contain valid JSON.',
      );
    }

    final email = body['email'];
    final password = body['password'];
    final displayName = body['displayName'];

    if (email is! String ||
        password is! String ||
        displayName is! String) {
      return ApiResponse.error(
        statusCode: HttpStatus.badRequest,
        code: 'INVALID_REQUEST',
        message:
            'Email, password and displayName are required.',
      );
    }

    final normalizedEmail = email.trim().toLowerCase();
    final normalizedDisplayName = displayName.trim();

    if (normalizedEmail.isEmpty) {
      return ApiResponse.error(
        statusCode: HttpStatus.badRequest,
        code: 'INVALID_EMAIL',
        message: 'Email is required.',
      );
    }

    if (!_isValidEmail(normalizedEmail)) {
      return ApiResponse.error(
        statusCode: HttpStatus.badRequest,
        code: 'INVALID_EMAIL',
        message: 'Please provide a valid email address.',
      );
    }

    if (password.isEmpty) {
      return ApiResponse.error(
        statusCode: HttpStatus.badRequest,
        code: 'INVALID_PASSWORD',
        message: 'Password is required.',
      );
    }

    if (normalizedDisplayName.isEmpty) {
      return ApiResponse.error(
        statusCode: HttpStatus.badRequest,
        code: 'INVALID_DISPLAY_NAME',
        message: 'Display name is required.',
      );
    }

    final existingUser =
        await UserRepository.findByEmail(normalizedEmail);

    if (existingUser != null) {
      return ApiResponse.error(
        statusCode: HttpStatus.conflict,
        code: 'EMAIL_ALREADY_EXISTS',
        message: 'An account with this email already exists.',
      );
    }

    try {
      final result = await AuthApiService.register(
        email: normalizedEmail,
        password: password,
        displayName: normalizedDisplayName,
      );

      final user =
          await UserRepository.findById(result.userId);

      if (user == null) {
        return ApiResponse.error(
          statusCode: HttpStatus.internalServerError,
          code: 'REGISTRATION_FAILED',
          message: 'Unable to load the newly created user.',
        );
      }

      return ApiResponse.success(
        statusCode: HttpStatus.created,
        data: {
          'user': user.toPublicMap(),
        },
      );
    } catch (_) {
      return ApiResponse.error(
        statusCode: HttpStatus.internalServerError,
        code: 'REGISTRATION_FAILED',
        message: 'Unable to create the account.',
      );
    }
  }

  Future<Response> _login(Request request) async {
    final body = await ApiResponse.readJsonBody(request);

    if (body == null) {
      return ApiResponse.error(
        statusCode: HttpStatus.badRequest,
        code: 'INVALID_JSON',
        message: 'Request body must contain valid JSON.',
      );
    }

    final email = body['email'];
    final password = body['password'];

    if (email is! String || password is! String) {
      return ApiResponse.error(
        statusCode: HttpStatus.badRequest,
        code: 'INVALID_REQUEST',
        message: 'Email and password are required.',
      );
    }

    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty || password.isEmpty) {
      return ApiResponse.error(
        statusCode: HttpStatus.badRequest,
        code: 'INVALID_CREDENTIALS',
        message: 'Email and password are required.',
      );
    }

    try {
      final result = await AuthApiService.login(
        email: normalizedEmail,
        password: password,
      );

      return ApiResponse.success(
        data: {
          'user': result.user.toPublicMap(),
          'session': {
            'token': result.session.token,
            'expiresAt':
                result.session.expiresAt.toUtc().toIso8601String(),
          },
        },
      );
    } catch (_) {
      return ApiResponse.error(
        statusCode: HttpStatus.unauthorized,
        code: 'INVALID_CREDENTIALS',
        message: 'Invalid email or password.',
      );
    }
  }

  Future<Response> _logout(Request request) async {
    final authorization =
        request.headers[HttpHeaders.authorizationHeader];

    if (authorization == null ||
        authorization.trim().isEmpty) {
      return ApiResponse.error(
        statusCode: HttpStatus.unauthorized,
        code: 'AUTH_REQUIRED',
        message: 'Authentication is required.',
      );
    }

    final parts = authorization.trim().split(' ');

    if (parts.length != 2 ||
        parts[0].toLowerCase() != 'bearer' ||
        parts[1].trim().isEmpty) {
      return ApiResponse.error(
        statusCode: HttpStatus.unauthorized,
        code: 'INVALID_AUTH_HEADER',
        message: 'Invalid authentication header.',
      );
    }

    final token = parts[1].trim();

    try {
      final session =
          await AuthenticationService.authenticateToken(token);

      if (session == null) {
        return ApiResponse.error(
          statusCode: HttpStatus.unauthorized,
          code: 'INVALID_SESSION',
          message: 'Session is invalid or expired.',
        );
      }

      await AuthenticationService.logout(token);

      return ApiResponse.success(
        data: {
          'loggedOut': true,
        },
      );
    } catch (_) {
      return ApiResponse.error(
        statusCode: HttpStatus.unauthorized,
        code: 'INVALID_SESSION',
        message: 'Session is invalid or expired.',
      );
    }
  }

  Future<Response> _me(Request request) async {
    final user = AuthMiddleware.getUser(request);

    if (user == null) {
      return ApiResponse.error(
        statusCode: HttpStatus.unauthorized,
        code: 'AUTH_REQUIRED',
        message: 'Authentication is required.',
      );
    }

    return ApiResponse.success(
      data: {
        'user': user.toPublicMap(),
      },
    );
  }

  static bool _isValidEmail(String email) {
    final emailPattern = RegExp(
      r'^[A-Za-z0-9.!#$%&*+/=?^_`{|}~-]+@'
      r'[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}'
      r'[A-Za-z0-9])?(?:\.[A-Za-z0-9]'
      r'(?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$',
    );

    return emailPattern.hasMatch(email);
  }

  static DateTime? _extractAccessTokenExpiry(
    String accessToken,
  ) {
    try {
      final parts = accessToken.split('.');

      if (parts.length != 3) {
        return null;
      }

      final normalizedPayload =
          base64Url.normalize(parts[1]);

      final payloadBytes =
          base64Url.decode(normalizedPayload);

      final payload =
          jsonDecode(utf8.decode(payloadBytes));

      if (payload is! Map) {
        return null;
      }

      final exp = payload['exp'];

      if (exp is int) {
        return DateTime.fromMillisecondsSinceEpoch(
          exp * 1000,
          isUtc: true,
        );
      }

      if (exp is num) {
        return DateTime.fromMillisecondsSinceEpoch(
          exp.toInt() * 1000,
          isUtc: true,
        );
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}