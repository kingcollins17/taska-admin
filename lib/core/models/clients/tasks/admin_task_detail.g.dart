// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_task_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminTaskDetail _$AdminTaskDetailFromJson(Map<String, dynamic> json) =>
    AdminTaskDetail(
      id: json['id'] as String?,
      customerId: json['customer_id'] as String?,
      regionId: json['region_id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
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
      dispatchStatus: json['dispatch_status'] as String?,
      nextDispatchAt: json['next_dispatch_at'] == null
          ? null
          : DateTime.parse(json['next_dispatch_at'] as String),
      autoDispatchCount: (json['auto_dispatch_count'] as num?)?.toInt(),
      manualDispatchCount: (json['manual_dispatch_count'] as num?)?.toInt(),
      paymentStatus: json['payment_status'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      scheduledStartAt: json['scheduled_start_at'] == null
          ? null
          : DateTime.parse(json['scheduled_start_at'] as String),
      startPin: json['start_pin'] as String?,
      completionPin: json['completion_pin'] as String?,
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      cancellationReason: json['cancellation_reason'] as String?,
      cancelledBy: json['cancelled_by'] as String?,
      locations: (json['locations'] as List<dynamic>?)
          ?.map((e) => AdminTaskLocation.fromJson(e as Map<String, dynamic>))
          .toList(),
      assignment: json['assignment'] == null
          ? null
          : AdminTaskAssignment.fromJson(
              json['assignment'] as Map<String, dynamic>,
            ),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => AdminTaskAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
      customer: json['customer'] == null
          ? null
          : AdminTaskCustomer.fromJson(
              json['customer'] as Map<String, dynamic>,
            ),
      payout: json['payout'] == null
          ? null
          : AdminTaskPayout.fromJson(json['payout'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AdminTaskDetailToJson(AdminTaskDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'region_id': instance.regionId,
      'title': instance.title,
      'description': instance.description,
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
      'dispatch_status': instance.dispatchStatus,
      'next_dispatch_at': instance.nextDispatchAt?.toIso8601String(),
      'auto_dispatch_count': instance.autoDispatchCount,
      'manual_dispatch_count': instance.manualDispatchCount,
      'payment_status': instance.paymentStatus,
      'created_at': instance.createdAt?.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
      'scheduled_start_at': instance.scheduledStartAt?.toIso8601String(),
      'start_pin': instance.startPin,
      'completion_pin': instance.completionPin,
      'updated_at': instance.updatedAt?.toIso8601String(),
      'cancellation_reason': instance.cancellationReason,
      'cancelled_by': instance.cancelledBy,
      'locations': instance.locations,
      'assignment': instance.assignment,
      'attachments': instance.attachments,
      'customer': instance.customer,
      'payout': instance.payout,
    };
