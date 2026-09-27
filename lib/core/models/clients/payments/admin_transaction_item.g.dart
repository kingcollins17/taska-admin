// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_transaction_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminTransactionItem _$AdminTransactionItemFromJson(
  Map<String, dynamic> json,
) => AdminTransactionItem(
  id: json['id'] as String?,
  amount: json['amount'] as num?,
  transactionType: json['transaction_type'] as String?,
  status: json['status'] as String?,
  userId: json['user_id'] as String?,
  taskId: json['task_id'] as String?,
  reference: json['reference'] as String?,
  metadataInfo: json['metadata_info'] as Map<String, dynamic>?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  task: json['task'] == null
      ? null
      : AdminPaymentTask.fromJson(json['task'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AdminTransactionItemToJson(
  AdminTransactionItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'transaction_type': instance.transactionType,
  'status': instance.status,
  'user_id': instance.userId,
  'task_id': instance.taskId,
  'reference': instance.reference,
  'metadata_info': instance.metadataInfo,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'task': instance.task,
};
