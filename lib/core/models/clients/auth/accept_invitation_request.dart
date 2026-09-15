import 'package:json_annotation/json_annotation.dart';

part 'accept_invitation_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AcceptInvitationRequest {
  final String? token;
  final String? password;
  final String? fullname;

  const AcceptInvitationRequest({
    this.token,
    this.password,
    this.fullname,
  });

  factory AcceptInvitationRequest.fromJson(Map<String, dynamic> json) =>
      _$AcceptInvitationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AcceptInvitationRequestToJson(this);
}
