// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_support_case_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminSupportCaseDetail _$AdminSupportCaseDetailFromJson(
  Map<String, dynamic> json,
) => AdminSupportCaseDetail(
  id: json['id'] as String?,
  caseNumber: json['case_number'] as String?,
  type: json['type'] as String?,
  status: json['status'] as String?,
  priority: json['priority'] as String?,
  customerId: json['customer_id'] as String?,
  providerId: json['provider_id'] as String?,
  initiatedBy: json['initiated_by'] as String?,
  initiator: json['initiator'] == null
      ? null
      : AdminSupportCaseInitiator.fromJson(
          json['initiator'] as Map<String, dynamic>,
        ),
  taskId: json['task_id'] as String?,
  assignmentId: json['assignment_id'] as String?,
  payoutId: json['payout_id'] as String?,
  subject: json['subject'] as String?,
  description: json['description'] as String?,
  assignedAgentId: json['assigned_agent_id'] as String?,
  replyToken: json['reply_token'] as String?,
  firstResponseDueAt: json['first_response_due_at'] as String?,
  resolutionDueAt: json['resolution_due_at'] as String?,
  firstRespondedAt: json['first_responded_at'] as String?,
  resolvedAt: json['resolved_at'] as String?,
  closedAt: json['closed_at'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  customer: json['customer'] as Map<String, dynamic>?,
  provider: json['provider'] as Map<String, dynamic>?,
  task: json['task'] as Map<String, dynamic>?,
  assignment: json['assignment'] as Map<String, dynamic>?,
  payout: json['payout'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$AdminSupportCaseDetailToJson(
  AdminSupportCaseDetail instance,
) => <String, dynamic>{
  'id': instance.id,
  'case_number': instance.caseNumber,
  'type': instance.type,
  'status': instance.status,
  'priority': instance.priority,
  'customer_id': instance.customerId,
  'provider_id': instance.providerId,
  'initiated_by': instance.initiatedBy,
  'initiator': instance.initiator,
  'task_id': instance.taskId,
  'assignment_id': instance.assignmentId,
  'payout_id': instance.payoutId,
  'subject': instance.subject,
  'description': instance.description,
  'assigned_agent_id': instance.assignedAgentId,
  'reply_token': instance.replyToken,
  'first_response_due_at': instance.firstResponseDueAt,
  'resolution_due_at': instance.resolutionDueAt,
  'first_responded_at': instance.firstRespondedAt,
  'resolved_at': instance.resolvedAt,
  'closed_at': instance.closedAt,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'customer': instance.customer,
  'provider': instance.provider,
  'task': instance.task,
  'assignment': instance.assignment,
  'payout': instance.payout,
};
