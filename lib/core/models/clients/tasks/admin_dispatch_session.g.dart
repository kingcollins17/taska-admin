// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dispatch_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminDispatchSession _$AdminDispatchSessionFromJson(
  Map<String, dynamic> json,
) => AdminDispatchSession(
  id: json['id'] as String?,
  taskId: json['task_id'] as String?,
  trigger: json['trigger'] as String?,
  status: json['status'] as String?,
  sequence: (json['sequence'] as num?)?.toInt(),
  startedAt: json['started_at'] == null
      ? null
      : DateTime.parse(json['started_at'] as String),
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
  reason: json['reason'] as String?,
  sessionMetadata: json['session_metadata'] as Map<String, dynamic>?,
  batchSize: (json['batch_size'] as num?)?.toInt(),
  searchRadiusKm: json['search_radius_km'] as num?,
  excludedProviderIds: (json['excluded_provider_ids'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$AdminDispatchSessionToJson(
  AdminDispatchSession instance,
) => <String, dynamic>{
  'id': instance.id,
  'task_id': instance.taskId,
  'trigger': instance.trigger,
  'status': instance.status,
  'sequence': instance.sequence,
  'started_at': instance.startedAt?.toIso8601String(),
  'completed_at': instance.completedAt?.toIso8601String(),
  'reason': instance.reason,
  'session_metadata': instance.sessionMetadata,
  'batch_size': instance.batchSize,
  'search_radius_km': instance.searchRadiusKm,
  'excluded_provider_ids': instance.excludedProviderIds,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
