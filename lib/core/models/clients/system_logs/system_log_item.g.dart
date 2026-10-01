// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_log_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SystemLogItem _$SystemLogItemFromJson(Map<String, dynamic> json) =>
    SystemLogItem(
      id: json['id'] as String?,
      level: json['level'] as String?,
      message: json['message'] as String?,
      source: json['source'] as String?,
      durationMs: json['duration_ms'] as num?,
      metadata: json['metadata_'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$SystemLogItemToJson(SystemLogItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'level': instance.level,
      'message': instance.message,
      'source': instance.source,
      'duration_ms': instance.durationMs,
      'metadata_': instance.metadata,
      'created_at': instance.createdAt?.toIso8601String(),
    };
