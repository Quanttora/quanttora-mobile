import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import 'upstox_config.dart';

class UpstoxAuthService {
  Future<String?> login() async {
    final authUrl =
        '${UpstoxConfig.authorizationUrl}'
        '?response_type=code'
        '&client_id=${UpstoxConfig.clientId}'
        '&redirect_uri=${Uri.encodeComponent(UpstoxConfig.redirectUri)}';

    final result = await FlutterWebAuth2.authenticate(
      url: authUrl,
      callbackUrlScheme: 'http',
    );

    return result;
  }
}
