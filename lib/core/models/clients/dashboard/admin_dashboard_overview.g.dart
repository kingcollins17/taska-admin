// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_overview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminDashboardOverview _$AdminDashboardOverviewFromJson(
  Map<String, dynamic> json,
) => AdminDashboardOverview(
  totalUsers: (json['total_users'] as num?)?.toInt(),
  totalCustomers: (json['total_customers'] as num?)?.toInt(),
  totalProviders: (json['total_providers'] as num?)?.toInt(),
  totalTasks: (json['total_tasks'] as num?)?.toInt(),
  totalCompletedTasks: (json['total_completed_tasks'] as num?)?.toInt(),
  totalInProgressTasks: (json['total_in_progress_tasks'] as num?)?.toInt(),
  totalOpenTasks: (json['total_open_tasks'] as num?)?.toInt(),
  totalCancelledTasks: (json['total_cancelled_tasks'] as num?)?.toInt(),
  totalRevenueAmount: (json['total_revenue_amount'] as num?)?.toDouble(),
  totalProcessedPayoutsAmount: (json['total_processed_payouts_amount'] as num?)
      ?.toDouble(),
);

Map<String, dynamic> _$AdminDashboardOverviewToJson(
  AdminDashboardOverview instance,
) => <String, dynamic>{
  'total_users': instance.totalUsers,
  'total_customers': instance.totalCustomers,
  'total_providers': instance.totalProviders,
  'total_tasks': instance.totalTasks,
  'total_completed_tasks': instance.totalCompletedTasks,
  'total_in_progress_tasks': instance.totalInProgressTasks,
  'total_open_tasks': instance.totalOpenTasks,
  'total_cancelled_tasks': instance.totalCancelledTasks,
  'total_revenue_amount': instance.totalRevenueAmount,
  'total_processed_payouts_amount': instance.totalProcessedPayoutsAmount,
};
