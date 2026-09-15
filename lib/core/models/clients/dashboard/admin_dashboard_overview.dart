import 'package:json_annotation/json_annotation.dart';

part 'admin_dashboard_overview.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminDashboardOverview {
  final int? totalUsers;
  final int? totalCustomers;
  final int? totalProviders;
  final int? totalTasks;
  final int? totalCompletedTasks;
  final int? totalInProgressTasks;
  final int? totalOpenTasks;
  final int? totalCancelledTasks;
  final double? totalRevenueAmount;
  final double? totalProcessedPayoutsAmount;

  const AdminDashboardOverview({
    this.totalUsers,
    this.totalCustomers,
    this.totalProviders,
    this.totalTasks,
    this.totalCompletedTasks,
    this.totalInProgressTasks,
    this.totalOpenTasks,
    this.totalCancelledTasks,
    this.totalRevenueAmount,
    this.totalProcessedPayoutsAmount,
  });

  factory AdminDashboardOverview.fromJson(Map<String, dynamic> json) =>
      _$AdminDashboardOverviewFromJson(json);

  Map<String, dynamic> toJson() => _$AdminDashboardOverviewToJson(this);
}
