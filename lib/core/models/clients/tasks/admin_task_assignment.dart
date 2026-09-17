import 'package:json_annotation/json_annotation.dart';

part 'admin_task_assignment.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminTaskAssignment {
  final String? id;
  final String? taskId;
  final String? providerId;
  final String? acceptedDispatchAttemptId;
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? identityPin;
  final String? cancellationPin;
  final String? status;

  const AdminTaskAssignment({
    this.id,
    this.taskId,
    this.providerId,
    this.acceptedDispatchAttemptId,
    this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.identityPin,
    this.cancellationPin,
    this.status,
  });

  factory AdminTaskAssignment.fromJson(Map<String, dynamic> json) =>
      _$AdminTaskAssignmentFromJson(json);

  Map<String, dynamic> toJson() => _$AdminTaskAssignmentToJson(this);
}
