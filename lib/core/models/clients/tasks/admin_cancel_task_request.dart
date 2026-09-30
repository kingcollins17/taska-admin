import 'package:json_annotation/json_annotation.dart';

part 'admin_cancel_task_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminCancelTaskRequest {
  final String? cancellationReason;
  final String? cancellationPin;

  const AdminCancelTaskRequest({
    this.cancellationReason,
    this.cancellationPin,
  });

  factory AdminCancelTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$AdminCancelTaskRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AdminCancelTaskRequestToJson(this);
}
