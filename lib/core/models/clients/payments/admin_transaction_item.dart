import 'package:json_annotation/json_annotation.dart';

import 'admin_payment_task.dart';

part 'admin_transaction_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminTransactionItem {
  final String? id;
  final num? amount;
  final String? transactionType;
  final String? status;
  final String? userId;
  final String? taskId;
  final String? reference;
  final Map<String, dynamic>? metadataInfo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final AdminPaymentTask? task;

  const AdminTransactionItem({
    this.id,
    this.amount,
    this.transactionType,
    this.status,
    this.userId,
    this.taskId,
    this.reference,
    this.metadataInfo,
    this.createdAt,
    this.updatedAt,
    this.task,
  });

  factory AdminTransactionItem.fromJson(Map<String, dynamic> json) =>
      _$AdminTransactionItemFromJson(json);

  Map<String, dynamic> toJson() => _$AdminTransactionItemToJson(this);
}
