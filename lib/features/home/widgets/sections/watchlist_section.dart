import 'package:flutter/material.dart';

import '../common/error_card.dart';
import '../common/loading_card.dart';
import '../watchlist_card.dart';

class WatchlistSection extends StatelessWidget {
  final bool loading;
  final String? error;
  final List<dynamic>? watchlist;

  const WatchlistSection({
    super.key,
    required this.loading,
    required this.watchlist,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const LoadingCard(
        message: "Loading Watchlist...",
      );
    }

    if (error != null) {
      return ErrorCard(
        message: error!,
      );
    }

    return const WatchlistCard();
  }
}