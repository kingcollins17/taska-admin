import 'package:json_annotation/json_annotation.dart';

part 'admin_assign_support_case_body.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminAssignSupportCaseBody {
  final String agentId;
  final String? reason;

  const AdminAssignSupportCaseBody({
    required this.agentId,
    this.reason,
  });

  factory AdminAssignSupportCaseBody.fromJson(Map<String, dynamic> json) =>
      _$AdminAssignSupportCaseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$AdminAssignSupportCaseBodyToJson(this);
}
