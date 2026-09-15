// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponseData _$LoginResponseDataFromJson(Map<String, dynamic> json) =>
    LoginResponseData(
      accessToken: json['access_token'] as String?,
      tokenType: json['token_type'] as String?,
      refreshToken: json['refresh_token'] as String?,
      admin: json['admin'] == null
          ? null
          : AdminUser.fromJson(json['admin'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseDataToJson(LoginResponseData instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'refresh_token': instance.refreshToken,
      'admin': instance.admin,
    };
