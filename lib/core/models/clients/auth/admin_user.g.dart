// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminUser _$AdminUserFromJson(Map<String, dynamic> json) => AdminUser(
  id: json['id'] as String?,
  email: json['email'] as String?,
  fullname: json['fullname'] as String?,
  role: json['role'] as String?,
  parentAdminId: json['parent_admin_id'] as String?,
  createdById: json['created_by_id'] as String?,
  regionId: json['region_id'] as String?,
  region: json['region'] == null
      ? null
      : AdminRegion.fromJson(json['region'] as Map<String, dynamic>),
  isActive: json['is_active'] as bool?,
  lastLoginAt: json['last_login_at'] == null
      ? null
      : DateTime.parse(json['last_login_at'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$AdminUserToJson(AdminUser instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'fullname': instance.fullname,
  'role': instance.role,
  'parent_admin_id': instance.parentAdminId,
  'created_by_id': instance.createdById,
  'region_id': instance.regionId,
  'region': instance.region,
  'is_active': instance.isActive,
  'last_login_at': instance.lastLoginAt?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
