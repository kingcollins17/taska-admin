import 'package:json_annotation/json_annotation.dart';

part 'admin_user_status_update_body.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminUserStatusUpdateBody {
  final String? reason;
  final Map<String, dynamic>? metaData;

  const AdminUserStatusUpdateBody({
    this.reason,
    this.metaData,
  });

  factory AdminUserStatusUpdateBody.fromJson(Map<String, dynamic> json) =>
      _$AdminUserStatusUpdateBodyFromJson(json);

  Map<String, dynamic> toJson() => _$AdminUserStatusUpdateBodyToJson(this);
}
