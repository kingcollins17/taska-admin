import 'package:json_annotation/json_annotation.dart';

part 'system_log_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SystemLogItem {
  final String? id;
  final String? level;
  final String? message;
  final String? source;
  final num? durationMs;
  @JsonKey(name: 'metadata_')
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;

  const SystemLogItem({
    this.id,
    this.level,
    this.message,
    this.source,
    this.durationMs,
    this.metadata,
    this.createdAt,
  });

  factory SystemLogItem.fromJson(Map<String, dynamic> json) =>
      _$SystemLogItemFromJson(json);

  Map<String, dynamic> toJson() => _$SystemLogItemToJson(this);
}
