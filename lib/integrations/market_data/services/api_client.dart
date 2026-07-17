import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  ApiClient._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.twelvedata.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  static Dio get client => _dio;

  static String get apiKey {
    final key = dotenv.env['TWELVE_DATA_API_KEY'];

    if (key == null || key.isEmpty) {
      throw Exception(
        'TWELVE_DATA_API_KEY not found. Please check your .env file.',
      );
    }

    return key;
  }
}