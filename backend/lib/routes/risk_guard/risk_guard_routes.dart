import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../services/risk_guard/risk_guard_service.dart';

class RiskGuardRoutes {
  final Router router = Router();

  RiskGuardRoutes() {
    router.post('/evaluate', _evaluate);
  }

  Future<Response> _evaluate(
    Request request,
  ) async {
    try {
      final body = jsonDecode(
        await request.readAsString(),
      );

      if (body is! Map<String, dynamic>) {
        return _json(
          {
            'success': false,
            'error': {
              'code': 'INVALID_REQUEST',
              'message':
                  'Request body must be a JSON object.',
            },
          },
          statusCode: 400,
        );
      }

      final requestData =
          RiskGuardRequest(
        capital: _requiredDouble(
          body,
          'capital',
        ),
        entryPrice: _requiredDouble(
          body,
          'entryPrice',
        ),
        stopLossPrice: _requiredDouble(
          body,
          'stopLossPrice',
        ),
        targetPrice: _requiredDouble(
          body,
          'targetPrice',
        ),
        quantity: _requiredInt(
          body,
          'quantity',
        ),
        maxRiskPerTrade:
            _requiredDouble(
          body,
          'maxRiskPerTrade',
        ),
        maxDailyLoss:
            _requiredDouble(
          body,
          'maxDailyLoss',
        ),
        maxTradesPerDay:
            _requiredInt(
          body,
          'maxTradesPerDay',
        ),
        tradesTakenToday:
            _requiredInt(
          body,
          'tradesTakenToday',
        ),
        dailyLossToday:
            _requiredDouble(
          body,
          'dailyLossToday',
        ),
        minimumRiskReward:
            _requiredDouble(
          body,
          'minimumRiskReward',
        ),
      );

      final result =
          RiskGuardService().evaluate(
        requestData,
      );

      return _json({
        'success': true,
        'data': result.toJson(),
      });
    } on FormatException catch (error) {
      return _json(
        {
          'success': false,
          'error': {
            'code': 'INVALID_REQUEST',
            'message': error.message,
          },
        },
        statusCode: 400,
      );
    } catch (error) {
      return _json(
        {
          'success': false,
          'error': {
            'code': 'RISK_GUARD_ERROR',
            'message':
                'Unable to evaluate the trade risk.',
          },
        },
        statusCode: 500,
      );
    }
  }

  double _requiredDouble(
    Map<String, dynamic> body,
    String key,
  ) {
    final value = body[key];

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      final parsed =
          double.tryParse(value);

      if (parsed != null) {
        return parsed;
      }
    }

    throw FormatException(
      '$key must be a valid number.',
    );
  }

  int _requiredInt(
    Map<String, dynamic> body,
    String key,
  ) {
    final value = body[key];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      final parsed =
          int.tryParse(value);

      if (parsed != null) {
        return parsed;
      }
    }

    throw FormatException(
      '$key must be a valid integer.',
    );
  }

  Response _json(
    Map<String, dynamic> body, {
    int statusCode = 200,
  }) {
    return Response(
      statusCode,
      body: jsonEncode(body),
      headers: {
        'content-type':
            'application/json',
      },
    );
  }
}