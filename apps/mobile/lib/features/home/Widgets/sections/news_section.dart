import 'package:flutter/material.dart';

import '../common/error_card.dart';
import '../common/loading_card.dart';
import '../news_card.dart';

class NewsSection extends StatelessWidget {
  final bool loading;
  final String? error;
  final List<dynamic>? news;

  const NewsSection({
    super.key,
    required this.loading,
    required this.news,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const LoadingCard(message: "Loading Market News...");
    }

    if (error != null) {
      return ErrorCard(message: error!);
    }

    return const NewsCard();
  }
}
