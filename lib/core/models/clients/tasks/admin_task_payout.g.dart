// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_task_payout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminTaskPayoutTask _$AdminTaskPayoutTaskFromJson(Map<String, dynamic> json) =>
    AdminTaskPayoutTask(
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

Map<String, dynamic> _$AdminTaskPayoutTaskToJson(
  AdminTaskPayoutTask instance,
) => <String, dynamic>{
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

AdminTaskPayout _$AdminTaskPayoutFromJson(Map<String, dynamic> json) =>
    AdminTaskPayout(
      id: json['id'] as String?,
      providerId: json['provider_id'] as String?,
      customerId: json['customer_id'] as String?,
      taskId: json['task_id'] as String?,
      payoutAmount: json['payout_amount'] as num?,
      customerPaymentAmount: json['customer_payment_amount'] as num?,
      status: json['status'] as String?,
      description: json['description'] as String?,
      paymentUrl: json['payment_url'] as String?,
      urlGeneratedAt: json['url_generated_at'] == null
          ? null
          : DateTime.parse(json['url_generated_at'] as String),
      reference: json['reference'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      task: json['task'] == null
          ? null
          : AdminTaskPayoutTask.fromJson(json['task'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AdminTaskPayoutToJson(AdminTaskPayout instance) =>
    <String, dynamic>{
      'id': instance.id,
      'provider_id': instance.providerId,
      'customer_id': instance.customerId,
      'task_id': instance.taskId,
      'payout_amount': instance.payoutAmount,
      'customer_payment_amount': instance.customerPaymentAmount,
      'status': instance.status,
      'description': instance.description,
      'payment_url': instance.paymentUrl,
      'url_generated_at': instance.urlGeneratedAt?.toIso8601String(),
      'reference': instance.reference,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'task': instance.task,
    };
