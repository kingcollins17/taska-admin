import 'package:json_annotation/json_annotation.dart';

import 'admin_task_assignment.dart';
import 'admin_task_category.dart';

part 'admin_task_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminTaskItem {
  final String? id;
  final String? customerId;
  final String? title;
  final String? categoryId;
  final String? serviceId;
  final num? basePrice;
  final num? distanceFee;
  final num? timeFee;
  final num? urgencyFee;
  final num? complexityFee;
  final num? surgeMultiplier;
  final num? customerTotalPrice;
  final num? platformFee;
  final num? providerPayout;
  final String? status;
  final DateTime? createdAt;
  final DateTime? scheduledStartAt;
  final num? distanceKm;
  final AdminTaskCategory? category;
  final AdminTaskAssignment? assignment;

  const AdminTaskItem({
    this.id,
    this.customerId,
    this.title,
    this.categoryId,
    this.serviceId,
    this.basePrice,
    this.distanceFee,
    this.timeFee,
    this.urgencyFee,
    this.complexityFee,
    this.surgeMultiplier,
    this.customerTotalPrice,
    this.platformFee,
    this.providerPayout,
    this.status,
    this.createdAt,
    this.scheduledStartAt,
    this.distanceKm,
    this.category,
    this.assignment,
  });

  factory AdminTaskItem.fromJson(Map<String, dynamic> json) =>
      _$AdminTaskItemFromJson(json);

  Map<String, dynamic> toJson() => _$AdminTaskItemToJson(this);
}
