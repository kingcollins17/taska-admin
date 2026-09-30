import 'package:json_annotation/json_annotation.dart';

part 'trigger_admin_redispatch_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TriggerAdminRedispatchRequest {
  final String? feedback;

  const TriggerAdminRedispatchRequest({
    this.feedback,
  });

  factory TriggerAdminRedispatchRequest.fromJson(Map<String, dynamic> json) =>
      _$TriggerAdminRedispatchRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TriggerAdminRedispatchRequestToJson(this);
}
