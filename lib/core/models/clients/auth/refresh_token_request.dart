import 'package:json_annotation/json_annotation.dart';

part 'refresh_token_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RefreshTokenRequest {
  final String? refreshToken;

  const RefreshTokenRequest({
    this.refreshToken,
  });

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}
