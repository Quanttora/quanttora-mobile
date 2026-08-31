import 'dart:io';

import 'package:test/test.dart';

void main() {
  late HttpServer server;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

    server.listen((request) {
      if (request.uri.path == '/') {
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.text
          ..write('Quanttora Backend\n')
          ..close();
        return;
      }

      request.response
        ..statusCode = HttpStatus.notFound
        ..close();
    });
  });

  tearDown(() async {
    await server.close(force: true);
  });

  test('Root', () async {
    final client = HttpClient();

    try {
      final request = await client.getUrl(
        Uri.parse('http://127.0.0.1:${server.port}/'),
      );

      final response = await request.close();
      final body = await response
          .transform(const SystemEncoding().decoder)
          .join();

      expect(response.statusCode, HttpStatus.ok);
      expect(body, 'Quanttora Backend\n');
    } finally {
      client.close(force: true);
    }
  });

  test('404', () async {
    final client = HttpClient();

    try {
      final request = await client.getUrl(
        Uri.parse('http://127.0.0.1:${server.port}/foobar'),
      );

      final response = await request.close();

      expect(response.statusCode, HttpStatus.notFound);
    } finally {
      client.close(force: true);
    }
  });
}
