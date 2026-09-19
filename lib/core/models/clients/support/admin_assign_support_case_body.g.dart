// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_assign_support_case_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminAssignSupportCaseBody _$AdminAssignSupportCaseBodyFromJson(
  Map<String, dynamic> json,
) => AdminAssignSupportCaseBody(
  agentId: json['agent_id'] as String,
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$AdminAssignSupportCaseBodyToJson(
  AdminAssignSupportCaseBody instance,
) => <String, dynamic>{'agent_id': instance.agentId, 'reason': instance.reason};
