import 'package:json_annotation/json_annotation.dart';

import 'admin_support_case_initiator.dart';

part 'admin_support_case_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminSupportCaseItem {
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

  const AdminSupportCaseItem({
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
  });

  factory AdminSupportCaseItem.fromJson(Map<String, dynamic> json) =>
      _$AdminSupportCaseItemFromJson(json);

  Map<String, dynamic> toJson() => _$AdminSupportCaseItemToJson(this);
}
