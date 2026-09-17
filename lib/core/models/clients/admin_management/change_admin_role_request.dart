import 'package:json_annotation/json_annotation.dart';

part 'change_admin_role_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ChangeAdminRoleRequest {
  final String newRole;

  const ChangeAdminRoleRequest({
    required this.newRole,
  });

  factory ChangeAdminRoleRequest.fromJson(Map<String, dynamic> json) =>
      _$ChangeAdminRoleRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChangeAdminRoleRequestToJson(this);
}
