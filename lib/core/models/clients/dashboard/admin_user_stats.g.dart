// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminUserStats _$AdminUserStatsFromJson(Map<String, dynamic> json) =>
    AdminUserStats(
      totalUsers: (json['total_users'] as num?)?.toInt(),
      totalActive: (json['total_active'] as num?)?.toInt(),
      totalInactive: (json['total_inactive'] as num?)?.toInt(),
      totalCustomers: (json['total_customers'] as num?)?.toInt(),
      totalProviders: (json['total_providers'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AdminUserStatsToJson(AdminUserStats instance) =>
    <String, dynamic>{
      'total_users': instance.totalUsers,
      'total_active': instance.totalActive,
      'total_inactive': instance.totalInactive,
      'total_customers': instance.totalCustomers,
      'total_providers': instance.totalProviders,
    };
