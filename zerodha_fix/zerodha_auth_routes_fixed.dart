import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:backend/api/api_response.dart';
import 'package:backend/integrations/upstox/upstox_auth_service.dart';
import 'package:backend/integrations/zerodha/zerodha_auth_service.dart';
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
  final ZerodhaAuthService _zerodha = ZerodhaAuthService();

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

  /*
   * OAuth state storage.
   *
   * Upstox redirects the browser to the callback endpoint and therefore
   * does not preserve the original Authorization header.
   *
   * We create a short-lived state value when the authenticated Quanttora
   * user starts broker authorization. The callback uses that state to
   * recover the Quanttora user ID.
   */
  static final Map<String, _UpstoxOAuthState> _oauthStates = {};

  static final Map<String, _ZerodhaOAuthState> _zerodhaOAuthStates = {};

  Router get router {
    final router = Router();

    router.post('/register', _register);

    router.post('/login', _login);

    router.post('/logout', _logout);

    router.get(
      '/me',
      AuthMiddleware.requireAuthentication()(_me),
    );

    /*
     * IMPORTANT:
     *
     * The login endpoint is authenticated because we need to know which
     * Quanttora user is starting the Upstox connection.
     */
    router.post(
      '/upstox/login',
      AuthMiddleware.requireAuthentication()(_upstoxLogin),
    );

    /*
     * Upstox callback is intentionally public.
     *
     * The authenticated Quanttora user is recovered through the OAuth
     * state created by /upstox/login.
     */
    router.get('/upstox/callback', _upstoxCallback);

    /*
     * Zerodha login endpoint is authenticated because we need to know which
     * Quanttora user is starting the Zerodha connection.
     */
    router.post(
      '/zerodha/login',
      AuthMiddleware.requireAuthentication()(_zerodhaLogin),
    );

    /*
     * Zerodha callback is public. The Quanttora user is recovered through
     * redirect_params/state created by /zerodha/login.
     */
    router.get('/zerodha/callback', _zerodhaCallback);

    return router;
  }

  Future<Response> _upstoxLogin(Request request) async {
    final user = AuthMiddleware.getUser(request);

    if (user == null) {
      return ApiResponse.error(
        statusCode: HttpStatus.unauthorized,
        code: 'AUTH_REQUIRED',
        message: 'Authentication is required.',
      );
    }

    _cleanupExpiredOAuthStates();

    final state = _generateOAuthState();

    _oauthStates[state] = _UpstoxOAuthState(
      userId: user.id,
      createdAt: DateTime.now().toUtc(),
    );

    final baseUrl = _upstox.getLoginUrl();

    final baseUri = Uri.parse(baseUrl);

    final loginUri = baseUri.replace(
      queryParameters: {
        ...baseUri.queryParameters,
        'state': state,
      },
    );

    print('');
    print('==============================');
    print('UPSTOX AUTHORIZATION STARTED');
    print('QUANTTORA USER ID: ${user.id}');
    print('STATE CREATED');
    print('==============================');
    print('');

    return Response.found(loginUri.toString());
  }

  Future<Response> _upstoxCallback(Request request) async {
    _cleanupExpiredOAuthStates();

    final queryParameters = request.requestedUri.queryParameters;

    final code = queryParameters['code'];
    final state = queryParameters['state'];
    final error = queryParameters['error'];
    final errorDescription = queryParameters['error_description'];

    if (error != null && error.isNotEmpty) {
      print('');
      print('==============================');
      print('UPSTOX AUTHORIZATION ERROR');
      print('ERROR: $error');
      print('DESCRIPTION: $errorDescription');
      print('==============================');
      print('');

      return Response(
        HttpStatus.badRequest,
        body: 'Upstox authorization was cancelled or failed.',
      );
    }

    if (state == null || state.trim().isEmpty) {
      print('UPSTOX CALLBACK ERROR: OAuth state missing.');

      return Response(
        HttpStatus.badRequest,
        body: 'OAuth state is missing.',
      );
    }

    final oauthState = _oauthStates.remove(state);

    if (oauthState == null) {
      print(
        'UPSTOX CALLBACK ERROR: Invalid or expired OAuth state.',
      );

      return Response(
        HttpStatus.badRequest,
        body: 'OAuth state is invalid or expired.',
      );
    }

    final quanttoraUserId = oauthState.userId;

    if (code == null || code.isEmpty) {
      print('');
      print('==============================');
      print('UPSTOX CALLBACK ERROR');
      print('Authorization code missing.');
      print('QUANTTORA USER ID: $quanttoraUserId');
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
      print('QUANTTORA USER ID: $quanttoraUserId');
      print('Exchanging code for access token...');
      print('==============================');
      print('');

      final token = await _upstox.exchangeCode(code: code);

      final accessToken = token['access_token']?.toString() ?? '';

      if (accessToken.isEmpty) {
        throw Exception(
          'Upstox access token was not returned.',
        );
      }

      print('UPSTOX TOKEN EXCHANGE SUCCESSFUL');

      /*
       * Standard Upstox OAuth does not require a refresh token for the
       * normal access-token lifecycle. Keep reading the field if Upstox
       * supplies one, so the backend remains forward-compatible.
       */
      final refreshToken = token['refresh_token']?.toString();

      final profileResponse = await http
          .get(
            Uri.parse(
              'https://api.upstox.com/v2/user/profile',
            ),
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

      final decodedProfile = jsonDecode(
        profileResponse.body,
      );

      if (decodedProfile is! Map) {
        throw Exception(
          'Invalid Upstox profile response.',
        );
      }

      final profileData = decodedProfile['data'];

      if (profileData is! Map) {
        throw Exception(
          'Invalid Upstox profile data.',
        );
      }

      final upstoxUserId =
          profileData['user_id']?.toString() ?? '';

      final userName =
          profileData['user_name']?.toString() ?? '';

      final email =
          profileData['email']?.toString() ?? '';

      if (upstoxUserId.isEmpty) {
        throw Exception(
          'Upstox user ID was not returned.',
        );
      }

      /*
       * Upstox standard access tokens remain valid until 3:30 AM
       * on the following day.
       */
      final accessTokenExpiresAt =
          _calculateUpstoxAccessTokenExpiry();

      /*
       * BrokerConnection keeps the Upstox identity.
       */
      final connection = BrokerConnection(
        broker: 'Upstox',
        userId: upstoxUserId,
        userName: userName,
        email: email,
        accessToken: accessToken,
        extendedToken:
            token['extended_token']?.toString() ?? '',
        refreshToken: refreshToken ?? '',
        accessTokenExpiresAt: accessTokenExpiresAt,
      );

      /*
       * Persist the broker connection against the
       * authenticated Quanttora user.
       */
      await _repository.save(
        connection,
        quanttoraUserId: quanttoraUserId,
      );

      /*
       * BrokerSession.userId is the Upstox user ID because that is the
       * broker identity.
       *
       * The session itself is stored against the Quanttora user ID below.
       */
      final session = BrokerSession(
        broker: connection.broker,
        userId: connection.userId,
        userName: connection.userName,
        email: connection.email,
        accessToken: accessToken,
        refreshToken: refreshToken,
        connectedAt: DateTime.now().toUtc(),
        accessTokenExpiresAt: accessTokenExpiresAt,
      );

      /*
       * The in-memory session remains available for the current process.
       */
      _brokerService.connectForUser(
        userId: quanttoraUserId,
        session: session,
      );

      print('BROKER SESSION CONNECTED');
      print('QUANTTORA USER ID: $quanttoraUserId');
      print('UPSTOX USER ID: $upstoxUserId');

      /*
       * Connect market feed after the broker session has been stored.
       */
      try {
        await _marketFeed.connect();

        await _marketFeed.subscribeMany(
          _marketInstruments,
        );

        print(
          'MARKET INSTRUMENTS SUBSCRIBED: '
          '${_marketInstruments.length}',
        );
      } catch (e, stackTrace) {
        /*
         * Broker connection itself succeeded.
         *
         * Market feed failure should not destroy the valid broker
         * session. Log it and allow the user to continue.
         */
        print('');
        print(
          'UPSTOX MARKET FEED CONNECTION WARNING',
        );
        print('ERROR: $e');
        print('STACK TRACE:');
        print(stackTrace);
        print('');
      }

      print('');
      print('==============================');
      print('UPSTOX CONNECTED');
      print('QUANTTORA USER ID: $quanttoraUserId');
      print('UPSTOX USER: ${connection.userName}');
      print('UPSTOX EMAIL: ${connection.email}');
      print(
        'MARKET INSTRUMENTS: '
        '${_marketInstruments.length}',
      );
      print(
        'ACCESS TOKEN EXPIRY: '
        '${accessTokenExpiresAt.toUtc().toIso8601String()}',
      );
      print(
        'REFRESH TOKEN: '
        '${refreshToken != null && refreshToken.isNotEmpty ? 'present' : 'not provided'}',
      );
      print('==============================');
      print('');

      return Response.found(
        'http://localhost:3000/broker-connected',
      );
    } catch (e, stackTrace) {
      print('');
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      print('UPSTOX CONNECTION FAILED');
      print('QUANTTORA USER ID: $quanttoraUserId');
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
  }

  Future<Response> _zerodhaLogin(Request request) async {
    final user = AuthMiddleware.getUser(request);

    if (user == null) {
      return ApiResponse.error(
        statusCode: HttpStatus.unauthorized,
        code: 'AUTH_REQUIRED',
        message: 'Authentication is required.',
      );
    }

    _cleanupExpiredZerodhaOAuthStates();

    final state = _generateOAuthState();

    _zerodhaOAuthStates[state] = _ZerodhaOAuthState(
      userId: user.id,
      createdAt: DateTime.now().toUtc(),
    );

    final baseUrl = _zerodha.getLoginUrl();
    final baseUri = Uri.parse(baseUrl);

    // Zerodha supports redirect_params and appends the supplied query
    // parameters to the configured redirect URL after successful login.
    final loginUri = baseUri.replace(
      queryParameters: {
        ...baseUri.queryParameters,
        'redirect_params': 'state=$state',
      },
    );

    print('');
    print('==============================');
    print('ZERODHA AUTHORIZATION STARTED');
    print('QUANTTORA USER ID: ${user.id}');
    print('STATE CREATED');
    print('==============================');
    print('');

    return Response.found(loginUri.toString());
  }

  Future<Response> _zerodhaCallback(Request request) async {
    _cleanupExpiredZerodhaOAuthStates();

    final queryParameters = request.requestedUri.queryParameters;

    final requestToken = queryParameters['request_token'];
    final status = queryParameters['status'];

    // Zerodha may return redirect_params as an encoded query-key when the
    // browser callback passes state=... through the redirect URL. In that
    // case Dart exposes the key as `state=<oauth-state>` with an empty value
    // instead of exposing a normal `state` parameter. Accept both forms.
    String? state = queryParameters['state'];

    if (state == null || state.trim().isEmpty) {
      for (final entry in queryParameters.entries) {
        final key = entry.key;

        if (key.startsWith('state=') && key.length > 'state='.length) {
          state = key.substring('state='.length);
          break;
        }
      }
    }

    state = state?.trim();

    if (status != null && status.toLowerCase() != 'success') {
      print('ZERODHA AUTHORIZATION ERROR: status=$status');
      return Response(
        HttpStatus.badRequest,
        body: 'Zerodha authorization was cancelled or failed.',
      );
    }

    if (state == null || state.trim().isEmpty) {
      print('ZERODHA CALLBACK ERROR: OAuth state missing.');
      return Response(
        HttpStatus.badRequest,
        body: 'OAuth state is missing.',
      );
    }

    final oauthState = _zerodhaOAuthStates.remove(state);

    if (oauthState == null) {
      print('ZERODHA CALLBACK ERROR: Invalid or expired OAuth state.');
      return Response(
        HttpStatus.badRequest,
        body: 'OAuth state is invalid or expired.',
      );
    }

    final quanttoraUserId = oauthState.userId;

    if (requestToken == null || requestToken.trim().isEmpty) {
      print('ZERODHA CALLBACK ERROR: Request token missing.');
      return Response(
        HttpStatus.badRequest,
        body: 'Zerodha request token is missing.',
      );
    }

    try {
      print('');
      print('==============================');
      print('ZERODHA CALLBACK RECEIVED');
      print('Request token received.');
      print('QUANTTORA USER ID: $quanttoraUserId');
      print('Exchanging request token for access token...');
      print('==============================');
      print('');

      final tokenResponse = await _zerodha.exchangeRequestToken(
        requestToken: requestToken,
      );

      final tokenData = tokenResponse['data'];

      if (tokenData is! Map) {
        throw Exception('Invalid Zerodha token response.');
      }

      final accessToken = tokenData['access_token']?.toString() ?? '';
      final zerodhaUserId = tokenData['user_id']?.toString() ?? '';
      final userName = tokenData['user_name']?.toString() ?? '';
      final email = tokenData['email']?.toString() ?? '';

      if (accessToken.isEmpty) {
        throw Exception('Zerodha access token was not returned.');
      }

      if (zerodhaUserId.isEmpty) {
        throw Exception('Zerodha user ID was not returned.');
      }

      print('ZERODHA TOKEN EXCHANGE SUCCESSFUL');

      final connection = BrokerConnection(
        broker: 'Zerodha',
        userId: zerodhaUserId,
        userName: userName,
        email: email,
        accessToken: accessToken,
        extendedToken: '',
        refreshToken: '',
        accessTokenExpiresAt: null,
      );

      await _repository.save(
        connection,
        quanttoraUserId: quanttoraUserId,
      );

      final session = BrokerSession(
        broker: connection.broker,
        userId: connection.userId,
        userName: connection.userName,
        email: connection.email,
        accessToken: accessToken,
        refreshToken: null,
        connectedAt: DateTime.now().toUtc(),
        accessTokenExpiresAt: null,
      );

      _brokerService.connectForUser(
        userId: quanttoraUserId,
        session: session,
      );

      print('');
      print('==============================');
      print('ZERODHA CONNECTED');
      print('QUANTTORA USER ID: $quanttoraUserId');
      print('ZERODHA USER ID: $zerodhaUserId');
      print('ZERODHA USER: ${connection.userName}');
      print('ZERODHA EMAIL: ${connection.email}');
      print('==============================');
      print('');

      return Response.found(
        'http://localhost:3000/broker-connected',
      );
    } catch (e, stackTrace) {
      print('');
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      print('ZERODHA CONNECTION FAILED');
      print('QUANTTORA USER ID: $quanttoraUserId');
      print('ERROR: $e');
      print('STACK TRACE:');
      print(stackTrace);
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      print('');

      return Response.internalServerError(
        body:
            'Zerodha connection failed. '
            'Check backend terminal for the exact error.',
      );
    }
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

    final normalizedEmail =
        email.trim().toLowerCase();

    final normalizedDisplayName =
        displayName.trim();

    if (normalizedEmail.isEmpty) {
      return ApiResponse.error(
        statusCode: HttpStatus.badRequest,
        code: 'INVALID_EMAIL',
        message: 'Email is required.',
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
        await UserRepository.findByEmail(
      normalizedEmail,
    );

    if (existingUser != null) {
      return ApiResponse.error(
        statusCode: HttpStatus.conflict,
        code: 'EMAIL_ALREADY_EXISTS',
        message:
            'An account with this email already exists.',
      );
    }

    try {
      final result = await AuthApiService.register(
        email: normalizedEmail,
        password: password,
        displayName: normalizedDisplayName,
      );

      final user =
          await UserRepository.findById(
        result.userId,
      );

      if (user == null) {
        return ApiResponse.error(
          statusCode: HttpStatus.internalServerError,
          code: 'REGISTRATION_FAILED',
          message:
              'Unable to load the newly created user.',
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
        message:
            'Email and password are required.',
      );
    }

    final normalizedEmail =
        email.trim().toLowerCase();

    if (normalizedEmail.isEmpty ||
        password.isEmpty) {
      return ApiResponse.error(
        statusCode: HttpStatus.badRequest,
        code: 'INVALID_CREDENTIALS',
        message:
            'Email and password are required.',
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
            'expiresAt': result.session.expiresAt
                .toUtc()
                .toIso8601String(),
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
        request.headers[
          HttpHeaders.authorizationHeader
        ];

    if (authorization == null ||
        authorization.trim().isEmpty) {
      return ApiResponse.error(
        statusCode: HttpStatus.unauthorized,
        code: 'AUTH_REQUIRED',
        message:
            'Authentication is required.',
      );
    }

    final parts =
        authorization.trim().split(' ');

    if (parts.length != 2 ||
        parts[0].toLowerCase() != 'bearer' ||
        parts[1].trim().isEmpty) {
      return ApiResponse.error(
        statusCode: HttpStatus.unauthorized,
        code: 'INVALID_AUTH_HEADER',
        message:
            'Invalid authentication header.',
      );
    }

    final token = parts[1].trim();

    try {
      final session =
          await AuthenticationService
              .authenticateToken(token);

      if (session == null) {
        return ApiResponse.error(
          statusCode: HttpStatus.unauthorized,
          code: 'INVALID_SESSION',
          message:
              'Session is invalid or expired.',
        );
      }

      await AuthenticationService.logout(
        token,
      );

      return ApiResponse.success(
        data: {'loggedOut': true},
      );
    } catch (_) {
      return ApiResponse.error(
        statusCode: HttpStatus.unauthorized,
        code: 'INVALID_SESSION',
        message:
            'Session is invalid or expired.',
      );
    }
  }

  Future<Response> _me(Request request) async {
    final user =
        AuthMiddleware.getUser(request);

    if (user == null) {
      return ApiResponse.error(
        statusCode: HttpStatus.unauthorized,
        code: 'AUTH_REQUIRED',
        message:
            'Authentication is required.',
      );
    }

    return ApiResponse.success(
      data: {
        'user': user.toPublicMap(),
      },
    );
  }

  String _generateOAuthState() {
    final random = Random.secure();

    final bytes = List<int>.generate(
      32,
      (_) => random.nextInt(256),
    );

    return base64Url
        .encode(bytes)
        .replaceAll('=', '');
  }

  void _cleanupExpiredOAuthStates() {
    final now = DateTime.now().toUtc();

    _oauthStates.removeWhere(
      (_, value) =>
          now.difference(value.createdAt) >
          const Duration(minutes: 10),
    );
  }

  void _cleanupExpiredZerodhaOAuthStates() {
    final now = DateTime.now().toUtc();

    _zerodhaOAuthStates.removeWhere(
      (_, value) =>
          now.difference(value.createdAt) >
          const Duration(minutes: 10),
    );
  }

  static DateTime _calculateUpstoxAccessTokenExpiry() {
    final now = DateTime.now();

    final tomorrow = DateTime(
      now.year,
      now.month,
      now.day + 1,
      3,
      30,
    );

    return tomorrow.toUtc();
  }
}

class _UpstoxOAuthState {
  final int userId;
  final DateTime createdAt;

  const _UpstoxOAuthState({
    required this.userId,
    required this.createdAt,
  });
}

class _ZerodhaOAuthState {
  final int userId;
  final DateTime createdAt;

  const _ZerodhaOAuthState({
    required this.userId,
    required this.createdAt,
  });
}