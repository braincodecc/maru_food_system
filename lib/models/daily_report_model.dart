class DailyReportModel {
  final DateTime date;
  final double totalSalesUsd;
  final double totalSalesBs;
  final int totalOrders;       // Todas las órdenes del día
  final int deliveredOrders;   // Solo las entregadas 🔥
  final double totalProfitUsd;
  final Map<String, int> topProducts;
  final Map<String, double> paymentMethods;

  DailyReportModel({
    required this.date,
    required this.totalSalesUsd,
    required this.totalSalesBs,
    required this.totalOrders,
    required this.deliveredOrders,
    required this.totalProfitUsd,
    required this.topProducts,
    required this.paymentMethods,
  });
}