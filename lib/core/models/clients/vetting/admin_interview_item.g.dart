// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_interview_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminInterviewItem _$AdminInterviewItemFromJson(Map<String, dynamic> json) =>
    AdminInterviewItem(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      adminId: json['admin_id'] as String?,
      scheduledAt: json['scheduled_at'] as String?,
      meetingLink: json['meeting_link'] as String?,
      status: json['status'] as String?,
      notes: json['notes'] as String?,
      passedAt: json['passed_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      metaData: json['meta_data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AdminInterviewItemToJson(AdminInterviewItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'admin_id': instance.adminId,
      'scheduled_at': instance.scheduledAt,
      'meeting_link': instance.meetingLink,
      'status': instance.status,
      'notes': instance.notes,
      'passed_at': instance.passedAt,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'meta_data': instance.metaData,
    };
