import 'package:json_annotation/json_annotation.dart';
import 'admin_user.dart';

part 'login_response_data.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LoginResponseData {
  final String? accessToken;
  final String? tokenType;
  final String? refreshToken;
  final AdminUser? admin;

  const LoginResponseData({
    this.accessToken,
    this.tokenType,
    this.refreshToken,
    this.admin,
  });

  factory LoginResponseData.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseDataToJson(this);
}
