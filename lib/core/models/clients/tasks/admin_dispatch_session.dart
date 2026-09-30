import 'package:json_annotation/json_annotation.dart';

part 'admin_dispatch_session.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminDispatchSession {
  final String? id;
  final String? taskId;
  final String? trigger;
  final String? status;
  final int? sequence;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? reason;
  final Map<String, dynamic>? sessionMetadata;
  final int? batchSize;
  final num? searchRadiusKm;
  final List<String>? excludedProviderIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminDispatchSession({
    this.id,
    this.taskId,
    this.trigger,
    this.status,
    this.sequence,
    this.startedAt,
    this.completedAt,
    this.reason,
    this.sessionMetadata,
    this.batchSize,
    this.searchRadiusKm,
    this.excludedProviderIds,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminDispatchSession.fromJson(Map<String, dynamic> json) =>
      _$AdminDispatchSessionFromJson(json);

  Map<String, dynamic> toJson() => _$AdminDispatchSessionToJson(this);
}
