// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_admin_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InviteAdminRequest _$InviteAdminRequestFromJson(Map<String, dynamic> json) =>
    InviteAdminRequest(
      email: json['email'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$InviteAdminRequestToJson(InviteAdminRequest instance) =>
    <String, dynamic>{'email': instance.email, 'role': instance.role};
