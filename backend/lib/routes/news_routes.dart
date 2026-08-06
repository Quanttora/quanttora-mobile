import 'dart:convert';

import 'package:backend/services/news/news_safety_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class NewsRoutes {
  final NewsSafetyService _newsSafetyService = NewsSafetyService();

  Router get router {
    final router = Router();

    router.get('/safety', _getNewsSafety);

    return router;
  }

  Future<Response> _getNewsSafety(Request request) async {
    final result = await _newsSafetyService.evaluate();

    return Response.ok(
      jsonEncode(result.toJson()),
      headers: {'content-type': 'application/json'},
    );
  }
}
