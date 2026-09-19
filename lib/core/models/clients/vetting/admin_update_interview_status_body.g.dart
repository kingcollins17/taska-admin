// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_update_interview_status_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminUpdateInterviewStatusBody _$AdminUpdateInterviewStatusBodyFromJson(
  Map<String, dynamic> json,
) => AdminUpdateInterviewStatusBody(
  status: json['status'] as String,
  notes: json['notes'] as String?,
  meetingLink: json['meeting_link'] as String?,
  scheduledAt: json['scheduled_at'] as String?,
);

Map<String, dynamic> _$AdminUpdateInterviewStatusBodyToJson(
  AdminUpdateInterviewStatusBody instance,
) => <String, dynamic>{
  'status': instance.status,
  'notes': instance.notes,
  'meeting_link': instance.meetingLink,
  'scheduled_at': instance.scheduledAt,
};
