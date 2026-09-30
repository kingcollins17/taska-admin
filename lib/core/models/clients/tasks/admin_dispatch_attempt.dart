import 'package:json_annotation/json_annotation.dart';

import 'admin_dispatch_attempt_provider.dart';

part 'admin_dispatch_attempt.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminDispatchAttempt {
  final String? id;
  final String? taskId;
  final String? dispatchSessionId;
  final String? providerId;
  final int? sequenceOrder;
  final num? matchScore;
  final num? offeredPayout;
  final DateTime? pingedAt;
  final DateTime? expiresAt;
  final DateTime? respondedAt;
  final String? status;
  final AdminDispatchAttemptProvider? provider;

  const AdminDispatchAttempt({
    this.id,
    this.taskId,
    this.dispatchSessionId,
    this.providerId,
    this.sequenceOrder,
    this.matchScore,
    this.offeredPayout,
    this.pingedAt,
    this.expiresAt,
    this.respondedAt,
    this.status,
    this.provider,
  });

  factory AdminDispatchAttempt.fromJson(Map<String, dynamic> json) =>
      _$AdminDispatchAttemptFromJson(json);

  Map<String, dynamic> toJson() => _$AdminDispatchAttemptToJson(this);
}
