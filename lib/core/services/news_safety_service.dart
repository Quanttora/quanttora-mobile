import '../network/api_client.dart';

class NewsSafetyResult {
  final bool dataAvailable;
  final bool highImpactNews;
  final String reason;
  final List<String> matchedHeadlines;

  const NewsSafetyResult({
    required this.dataAvailable,
    required this.highImpactNews,
    required this.reason,
    required this.matchedHeadlines,
  });

  factory NewsSafetyResult.fromJson(Map<String, dynamic> json) {
    final rawHeadlines = json['matchedHeadlines'];

    return NewsSafetyResult(
      dataAvailable: json['dataAvailable'] == true,
      highImpactNews: json['highImpactNews'] == true,
      reason: json['reason']?.toString() ?? '',
      matchedHeadlines: rawHeadlines is List
          ? rawHeadlines.map((item) => item.toString()).toList(growable: false)
          : const <String>[],
    );
  }
}

class NewsSafetyService {
  final ApiClient _api = ApiClient.instance;

  Future<NewsSafetyResult> evaluate() async {
    try {
      final response = await _api.get('/news/safety');

      return NewsSafetyResult.fromJson(response);
    } catch (_) {
      // Fail closed.
      return const NewsSafetyResult(
        dataAvailable: false,
        highImpactNews: false,
        reason: 'Reliable news-safety data is currently unavailable.',
        matchedHeadlines: [],
      );
    }
  }
}
