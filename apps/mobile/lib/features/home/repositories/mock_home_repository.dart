import '../models/home_dashboard_data.dart';
import 'home_repository.dart';

class MockHomeRepository implements HomeRepository {
  @override
  Future<HomeDashboardData> getDashboard() async {
    await Future.delayed(const Duration(milliseconds: 700));

    return HomeDashboardData(
      userName: "Sagar",
      portfolioValue: 482350,
      todayPnL: 6820,
      todayPnLPercent: 1.43,
      isProfit: true,
      aiScore: 84,
      marketOverview: const [
        MarketIndexData(
          name: "NIFTY 50",
          value: 25184.20,
          change: 184.25,
          changePercent: 0.74,
        ),
        MarketIndexData(
          name: "SENSEX",
          value: 82611.08,
          change: 536.70,
          changePercent: 0.65,
        ),
        MarketIndexData(
          name: "BANK NIFTY",
          value: 57228.15,
          change: -112.40,
          changePercent: -0.20,
        ),
      ],
      marketNews: const [
        MarketNewsData(
          title: "NIFTY closes higher as banking stocks lead gains.",
          source: "Moneycontrol",
          time: "10 min ago",
          highImpact: false,
        ),
        MarketNewsData(
          title: "RBI policy announcement expected this week.",
          source: "Economic Times",
          time: "28 min ago",
          highImpact: true,
        ),
        MarketNewsData(
          title: "FIIs remain net buyers in Indian equities.",
          source: "CNBC TV18",
          time: "45 min ago",
          highImpact: false,
        ),
      ],
    );
  }
}