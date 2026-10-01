import 'package:json_annotation/json_annotation.dart';

part 'system_log_stats.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SystemLogStats {
  final int? info;
  final int? warn;
  final int? error;
  final int? debug;
  final int? metric;

  const SystemLogStats({
    this.info,
    this.warn,
    this.error,
    this.debug,
    this.metric,
  });

  factory SystemLogStats.fromJson(Map<String, dynamic> json) =>
      _$SystemLogStatsFromJson(json);

  Map<String, dynamic> toJson() => _$SystemLogStatsToJson(this);
}
