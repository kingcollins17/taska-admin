// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_payment_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminPaymentTask _$AdminPaymentTaskFromJson(Map<String, dynamic> json) =>
    AdminPaymentTask(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String?,
      serviceId: json['service_id'] as String?,
      customerTotalPrice: json['customer_total_price'] as num?,
      platformFee: json['platform_fee'] as num?,
      providerPayout: json['provider_payout'] as num?,
      status: json['status'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$AdminPaymentTaskToJson(AdminPaymentTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category_id': instance.categoryId,
      'service_id': instance.serviceId,
      'customer_total_price': instance.customerTotalPrice,
      'platform_fee': instance.platformFee,
      'provider_payout': instance.providerPayout,
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
