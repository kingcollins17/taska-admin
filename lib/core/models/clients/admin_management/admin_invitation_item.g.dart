// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_invitation_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminInvitationItem _$AdminInvitationItemFromJson(Map<String, dynamic> json) =>
    AdminInvitationItem(
      id: json['id'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      invitedById: json['invited_by_id'] as String?,
      status: json['status'] as String?,
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AdminInvitationItemToJson(
  AdminInvitationItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'role': instance.role,
  'invited_by_id': instance.invitedById,
  'status': instance.status,
  'expires_at': instance.expiresAt?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
};
