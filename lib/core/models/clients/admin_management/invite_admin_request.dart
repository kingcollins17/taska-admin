import 'package:json_annotation/json_annotation.dart';

part 'invite_admin_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class InviteAdminRequest {
  final String email;
  final String role;

  const InviteAdminRequest({
    required this.email,
    required this.role,
  });

  factory InviteAdminRequest.fromJson(Map<String, dynamic> json) =>
      _$InviteAdminRequestFromJson(json);

  Map<String, dynamic> toJson() => _$InviteAdminRequestToJson(this);
}
