class HomeDashboardData {
  const HomeDashboardData({
    required this.userName,
    required this.portfolioValue,
    required this.todayPnL,
    required this.todayPnLPercent,
    required this.isProfit,
    required this.aiScore,
    required this.marketOverview,
    required this.marketNews,
  });

  final String userName;
  final double portfolioValue;
  final double todayPnL;
  final double todayPnLPercent;
  final bool isProfit;
  final int aiScore;

  final List<MarketIndexData> marketOverview;
  final List<MarketNewsData> marketNews;
}

class MarketIndexData {
  const MarketIndexData({
    required this.name,
    required this.value,
    required this.change,
    required this.changePercent,
  });

  final String name;
  final double value;
  final double change;
  final double changePercent;
}

class MarketNewsData {
  const MarketNewsData({
    required this.title,
    required this.source,
    required this.time,
    required this.highImpact,
    this.url,
  });

  final String title;
  final String source;
  final String time;
  final bool highImpact;
  final String? url;
}
