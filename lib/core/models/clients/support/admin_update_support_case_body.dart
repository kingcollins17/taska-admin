import 'package:json_annotation/json_annotation.dart';

part 'admin_update_support_case_body.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminUpdateSupportCaseBody {
  final String? status;
  final String? priority;
  final String? subject;
  final String? description;

  const AdminUpdateSupportCaseBody({
    this.status,
    this.priority,
    this.subject,
    this.description,
  });

  factory AdminUpdateSupportCaseBody.fromJson(Map<String, dynamic> json) =>
      _$AdminUpdateSupportCaseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$AdminUpdateSupportCaseBodyToJson(this);
}
