import 'package:json_annotation/json_annotation.dart';

part 'admin_task_payout.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminTaskPayoutTask {
  final String? id;
  final String? title;
  final String? description;
  final String? categoryId;
  final String? serviceId;
  final num? customerTotalPrice;
  final num? platformFee;
  final num? providerPayout;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminTaskPayoutTask({
    this.id,
    this.title,
    this.description,
    this.categoryId,
    this.serviceId,
    this.customerTotalPrice,
    this.platformFee,
    this.providerPayout,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminTaskPayoutTask.fromJson(Map<String, dynamic> json) =>
      _$AdminTaskPayoutTaskFromJson(json);

  Map<String, dynamic> toJson() => _$AdminTaskPayoutTaskToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminTaskPayout {
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
  final AdminTaskPayoutTask? task;

  const AdminTaskPayout({
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

  factory AdminTaskPayout.fromJson(Map<String, dynamic> json) =>
      _$AdminTaskPayoutFromJson(json);

  Map<String, dynamic> toJson() => _$AdminTaskPayoutToJson(this);
}
