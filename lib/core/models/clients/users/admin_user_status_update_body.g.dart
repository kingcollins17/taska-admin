// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_status_update_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminUserStatusUpdateBody _$AdminUserStatusUpdateBodyFromJson(
  Map<String, dynamic> json,
) => AdminUserStatusUpdateBody(
  reason: json['reason'] as String?,
  metaData: json['meta_data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$AdminUserStatusUpdateBodyToJson(
  AdminUserStatusUpdateBody instance,
) => <String, dynamic>{
  'reason': instance.reason,
  'meta_data': instance.metaData,
};
