import 'package:json_annotation/json_annotation.dart';

import 'admin_task_assignment.dart';
import 'admin_task_attachment.dart';
import 'admin_task_customer.dart';
import 'admin_task_location.dart';
import 'admin_task_payout.dart';

part 'admin_task_detail.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminTaskDetail {
  final String? id;
  final String? customerId;
  final String? regionId;
  final String? title;
  final String? description;
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
  final String? dispatchStatus;
  final DateTime? nextDispatchAt;
  final int? autoDispatchCount;
  final int? manualDispatchCount;
  final String? paymentStatus;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final DateTime? scheduledStartAt;
  final String? startPin;
  final String? completionPin;
  final DateTime? updatedAt;
  final String? cancellationReason;
  final String? cancelledBy;
  final List<AdminTaskLocation>? locations;
  final AdminTaskAssignment? assignment;
  final List<AdminTaskAttachment>? attachments;
  final AdminTaskCustomer? customer;
  final AdminTaskPayout? payout;

  const AdminTaskDetail({
    this.id,
    this.customerId,
    this.regionId,
    this.title,
    this.description,
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
    this.dispatchStatus,
    this.nextDispatchAt,
    this.autoDispatchCount,
    this.manualDispatchCount,
    this.paymentStatus,
    this.createdAt,
    this.expiresAt,
    this.scheduledStartAt,
    this.startPin,
    this.completionPin,
    this.updatedAt,
    this.cancellationReason,
    this.cancelledBy,
    this.locations,
    this.assignment,
    this.attachments,
    this.customer,
    this.payout,
  });

  factory AdminTaskDetail.fromJson(Map<String, dynamic> json) =>
      _$AdminTaskDetailFromJson(json);

  Map<String, dynamic> toJson() => _$AdminTaskDetailToJson(this);
}
