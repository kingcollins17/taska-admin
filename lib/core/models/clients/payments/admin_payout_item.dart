import 'package:json_annotation/json_annotation.dart';

import 'admin_payment_task.dart';

part 'admin_payout_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminPayoutItem {
  final String? id;
  final String? providerId;
  final String? customerId;
  final String? taskId;
  final num? payoutAmount;
  final num? customerPaymentAmount;
  final String? status;
  final String? description;
  final String? paymentUrl;
  final DateTime? urlGeneratedAt;
  final String? reference;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final AdminPaymentTask? task;

  const AdminPayoutItem({
    this.id,
    this.providerId,
    this.customerId,
    this.taskId,
    this.payoutAmount,
    this.customerPaymentAmount,
    this.status,
    this.description,
    this.paymentUrl,
    this.urlGeneratedAt,
    this.reference,
    this.createdAt,
    this.updatedAt,
    this.task,
  });

  factory AdminPayoutItem.fromJson(Map<String, dynamic> json) =>
      _$AdminPayoutItemFromJson(json);

  Map<String, dynamic> toJson() => _$AdminPayoutItemToJson(this);
}
