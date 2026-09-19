import 'package:json_annotation/json_annotation.dart';

import 'admin_support_case_initiator.dart';

part 'admin_support_case_detail.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminSupportCaseDetail {
  final String? id;
  final String? caseNumber;
  final String? type;
  final String? status;
  final String? priority;
  final String? customerId;
  final String? providerId;
  final String? initiatedBy;
  final AdminSupportCaseInitiator? initiator;
  final String? taskId;
  final String? assignmentId;
  final String? payoutId;
  final String? subject;
  final String? description;
  final String? assignedAgentId;
  final String? replyToken;
  final String? firstResponseDueAt;
  final String? resolutionDueAt;
  final String? firstRespondedAt;
  final String? resolvedAt;
  final String? closedAt;
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic>? customer;
  final Map<String, dynamic>? provider;
  final Map<String, dynamic>? task;
  final Map<String, dynamic>? assignment;
  final Map<String, dynamic>? payout;

  const AdminSupportCaseDetail({
    this.id,
    this.caseNumber,
    this.type,
    this.status,
    this.priority,
    this.customerId,
    this.providerId,
    this.initiatedBy,
    this.initiator,
    this.taskId,
    this.assignmentId,
    this.payoutId,
    this.subject,
    this.description,
    this.assignedAgentId,
    this.replyToken,
    this.firstResponseDueAt,
    this.resolutionDueAt,
    this.firstRespondedAt,
    this.resolvedAt,
    this.closedAt,
    this.createdAt,
    this.updatedAt,
    this.customer,
    this.provider,
    this.task,
    this.assignment,
    this.payout,
  });

  factory AdminSupportCaseDetail.fromJson(Map<String, dynamic> json) =>
      _$AdminSupportCaseDetailFromJson(json);

  Map<String, dynamic> toJson() => _$AdminSupportCaseDetailToJson(this);
}
