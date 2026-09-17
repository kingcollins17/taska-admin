// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_task_assignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminTaskAssignment _$AdminTaskAssignmentFromJson(Map<String, dynamic> json) =>
    AdminTaskAssignment(
      id: json['id'] as String?,
      taskId: json['task_id'] as String?,
      providerId: json['provider_id'] as String?,
      acceptedDispatchAttemptId:
          json['accepted_dispatch_attempt_id'] as String?,
      assignedAt: json['assigned_at'] == null
          ? null
          : DateTime.parse(json['assigned_at'] as String),
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      identityPin: json['identity_pin'] as String?,
      cancellationPin: json['cancellation_pin'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$AdminTaskAssignmentToJson(
  AdminTaskAssignment instance,
) => <String, dynamic>{
  'id': instance.id,
  'task_id': instance.taskId,
  'provider_id': instance.providerId,
  'accepted_dispatch_attempt_id': instance.acceptedDispatchAttemptId,
  'assigned_at': instance.assignedAt?.toIso8601String(),
  'started_at': instance.startedAt?.toIso8601String(),
  'completed_at': instance.completedAt?.toIso8601String(),
  'identity_pin': instance.identityPin,
  'cancellation_pin': instance.cancellationPin,
  'status': instance.status,
};
