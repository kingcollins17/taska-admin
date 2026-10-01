// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_log_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SystemLogStats _$SystemLogStatsFromJson(Map<String, dynamic> json) =>
    SystemLogStats(
      info: (json['info'] as num?)?.toInt(),
      warn: (json['warn'] as num?)?.toInt(),
      error: (json['error'] as num?)?.toInt(),
      debug: (json['debug'] as num?)?.toInt(),
      metric: (json['metric'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SystemLogStatsToJson(SystemLogStats instance) =>
    <String, dynamic>{
      'info': instance.info,
      'warn': instance.warn,
      'error': instance.error,
      'debug': instance.debug,
      'metric': instance.metric,
    };
