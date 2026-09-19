// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_update_support_case_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminUpdateSupportCaseBody _$AdminUpdateSupportCaseBodyFromJson(
  Map<String, dynamic> json,
) => AdminUpdateSupportCaseBody(
  status: json['status'] as String?,
  priority: json['priority'] as String?,
  subject: json['subject'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$AdminUpdateSupportCaseBodyToJson(
  AdminUpdateSupportCaseBody instance,
) => <String, dynamic>{
  'status': instance.status,
  'priority': instance.priority,
  'subject': instance.subject,
  'description': instance.description,
};
