import 'package:json_annotation/json_annotation.dart';

part 'admin_payment_task.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminPaymentTask {
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

  const AdminPaymentTask({
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

  factory AdminPaymentTask.fromJson(Map<String, dynamic> json) =>
      _$AdminPaymentTaskFromJson(json);

  Map<String, dynamic> toJson() => _$AdminPaymentTaskToJson(this);
}
