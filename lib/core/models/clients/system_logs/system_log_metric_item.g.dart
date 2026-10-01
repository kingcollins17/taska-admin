// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_log_metric_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SystemLogMetricItem _$SystemLogMetricItemFromJson(Map<String, dynamic> json) =>
    SystemLogMetricItem(
      source: json['source'] as String?,
      count: (json['count'] as num?)?.toInt(),
      avgDuration: json['avg_duration'] as num?,
      maxDuration: json['max_duration'] as num?,
      minDuration: json['min_duration'] as num?,
    );

Map<String, dynamic> _$SystemLogMetricItemToJson(
  SystemLogMetricItem instance,
) => <String, dynamic>{
  'source': instance.source,
  'count': instance.count,
  'avg_duration': instance.avgDuration,
  'max_duration': instance.maxDuration,
  'min_duration': instance.minDuration,
};
