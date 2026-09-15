// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accept_invitation_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcceptInvitationRequest _$AcceptInvitationRequestFromJson(
  Map<String, dynamic> json,
) => AcceptInvitationRequest(
  token: json['token'] as String?,
  password: json['password'] as String?,
  fullname: json['fullname'] as String?,
);

Map<String, dynamic> _$AcceptInvitationRequestToJson(
  AcceptInvitationRequest instance,
) => <String, dynamic>{
  'token': instance.token,
  'password': instance.password,
  'fullname': instance.fullname,
};
