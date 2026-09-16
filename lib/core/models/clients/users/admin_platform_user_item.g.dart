// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_platform_user_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminPlatformUserItem _$AdminPlatformUserItemFromJson(
  Map<String, dynamic> json,
) => AdminPlatformUserItem(
  id: json['id'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phone_number'] as String?,
  fullname: json['fullname'] as String?,
  type: json['type'] as String?,
  isActive: json['is_active'] as bool?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  regionId: json['region_id'] as String?,
);

Map<String, dynamic> _$AdminPlatformUserItemToJson(
  AdminPlatformUserItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'phone_number': instance.phoneNumber,
  'fullname': instance.fullname,
  'type': instance.type,
  'is_active': instance.isActive,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'region_id': instance.regionId,
};
