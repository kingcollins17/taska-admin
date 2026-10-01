import 'package:json_annotation/json_annotation.dart';

part 'system_log_metric_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SystemLogMetricItem {
  final String? source;
  final int? count;
  final num? avgDuration;
  final num? maxDuration;
  final num? minDuration;

  const SystemLogMetricItem({
    this.source,
    this.count,
    this.avgDuration,
    this.maxDuration,
    this.minDuration,
  });

  factory SystemLogMetricItem.fromJson(Map<String, dynamic> json) =>
      _$SystemLogMetricItemFromJson(json);

  Map<String, dynamic> toJson() => _$SystemLogMetricItemToJson(this);
}
