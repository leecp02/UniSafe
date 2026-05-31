class ReportDashboardStats {
  final int totalReports;
  final Map<String, int> categoryCounts;
  final Map<String, int> facultyCounts;
  final Map<String, int> statusCounts;

  const ReportDashboardStats({
    required this.totalReports,
    required this.categoryCounts,
    required this.facultyCounts,
    required this.statusCounts,
  });

  static const empty = ReportDashboardStats(
    totalReports: 0,
    categoryCounts: <String, int>{},
    facultyCounts: <String, int>{},
    statusCounts: <String, int>{},
  );
}
