import 'package:json_annotation/json_annotation.dart';

part 'admin_resolve_support_case_body.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminResolveSupportCaseBody {
  final String decision;
  final String reason;

  const AdminResolveSupportCaseBody({
    required this.decision,
    required this.reason,
  });

  factory AdminResolveSupportCaseBody.fromJson(Map<String, dynamic> json) =>
      _$AdminResolveSupportCaseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$AdminResolveSupportCaseBodyToJson(this);
}
