// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_task_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminTaskItem _$AdminTaskItemFromJson(Map<String, dynamic> json) =>
    AdminTaskItem(
      id: json['id'] as String?,
      customerId: json['customer_id'] as String?,
      title: json['title'] as String?,
      categoryId: json['category_id'] as String?,
      serviceId: json['service_id'] as String?,
      basePrice: json['base_price'] as num?,
      distanceFee: json['distance_fee'] as num?,
      timeFee: json['time_fee'] as num?,
      urgencyFee: json['urgency_fee'] as num?,
      complexityFee: json['complexity_fee'] as num?,
      surgeMultiplier: json['surge_multiplier'] as num?,
      customerTotalPrice: json['customer_total_price'] as num?,
      platformFee: json['platform_fee'] as num?,
      providerPayout: json['provider_payout'] as num?,
      status: json['status'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      scheduledStartAt: json['scheduled_start_at'] == null
          ? null
          : DateTime.parse(json['scheduled_start_at'] as String),
      distanceKm: json['distance_km'] as num?,
      category: json['category'] == null
          ? null
          : AdminTaskCategory.fromJson(
              json['category'] as Map<String, dynamic>,
            ),
      assignment: json['assignment'] == null
          ? null
          : AdminTaskAssignment.fromJson(
              json['assignment'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$AdminTaskItemToJson(AdminTaskItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'title': instance.title,
      'category_id': instance.categoryId,
      'service_id': instance.serviceId,
      'base_price': instance.basePrice,
      'distance_fee': instance.distanceFee,
      'time_fee': instance.timeFee,
      'urgency_fee': instance.urgencyFee,
      'complexity_fee': instance.complexityFee,
      'surge_multiplier': instance.surgeMultiplier,
      'customer_total_price': instance.customerTotalPrice,
      'platform_fee': instance.platformFee,
      'provider_payout': instance.providerPayout,
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
      'scheduled_start_at': instance.scheduledStartAt?.toIso8601String(),
      'distance_km': instance.distanceKm,
      'category': instance.category,
      'assignment': instance.assignment,
    };
