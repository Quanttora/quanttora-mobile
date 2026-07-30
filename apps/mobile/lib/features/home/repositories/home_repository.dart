import '../models/home_dashboard_data.dart';

abstract class HomeRepository {
  Future<HomeDashboardData> getDashboard();
}