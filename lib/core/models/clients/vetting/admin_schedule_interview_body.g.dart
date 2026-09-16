// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_schedule_interview_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminScheduleInterviewBody _$AdminScheduleInterviewBodyFromJson(
  Map<String, dynamic> json,
) => AdminScheduleInterviewBody(
  userId: json['user_id'] as String,
  scheduledAt: json['scheduled_at'] as String,
  meetingLink: json['meeting_link'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$AdminScheduleInterviewBodyToJson(
  AdminScheduleInterviewBody instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'scheduled_at': instance.scheduledAt,
  'meeting_link': instance.meetingLink,
  'notes': instance.notes,
};
