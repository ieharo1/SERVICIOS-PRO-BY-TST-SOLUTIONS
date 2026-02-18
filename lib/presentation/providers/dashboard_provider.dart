import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/quote_repository.dart';
import '../../data/repositories/work_order_repository.dart';

class DashboardData {
  final int monthlyQuotes;
  final int completedOrders;
  final double estimatedIncome;
  final int totalClients;
  final int totalQuotes;
  final int totalOrders;

  DashboardData({
    required this.monthlyQuotes,
    required this.completedOrders,
    required this.estimatedIncome,
    required this.totalClients,
    required this.totalQuotes,
    required this.totalOrders,
  });
}

final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final quoteRepo = ref.watch(quoteRepositoryProvider);
  final workOrderRepo = ref.watch(workOrderRepositoryProvider);
  
  final monthlyQuotes = await quoteRepo.getMonthlyQuoteCount();
  final completedOrders = await workOrderRepo.getMonthlyCompletedCount();
  final estimatedIncome = await quoteRepo.getMonthlyTotal();
  final totalClients = 0;
  final totalQuotes = await quoteRepo.getQuoteCount();
  final totalOrders = await workOrderRepo.getWorkOrderCount();
  
  return DashboardData(
    monthlyQuotes: monthlyQuotes,
    completedOrders: completedOrders,
    estimatedIncome: estimatedIncome,
    totalClients: totalClients,
    totalQuotes: totalQuotes,
    totalOrders: totalOrders,
  );
});

final quoteRepositoryProvider = Provider((ref) {
  return QuoteRepository();
});

final workOrderRepositoryProvider = Provider((ref) {
  return WorkOrderRepository();
});
