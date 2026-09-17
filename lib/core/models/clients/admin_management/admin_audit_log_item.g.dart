// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_audit_log_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminAuditLogItem _$AdminAuditLogItemFromJson(Map<String, dynamic> json) =>
    AdminAuditLogItem(
      id: json['id'] as String?,
      adminId: json['admin_id'] as String?,
      action: json['action'] as String?,
      resourceType: json['resource_type'] as String?,
      resourceId: json['resource_id'] as String?,
      metaData: json['meta_data'] as Map<String, dynamic>?,
      reason: json['reason'] as String?,
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AdminAuditLogItemToJson(AdminAuditLogItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'admin_id': instance.adminId,
      'action': instance.action,
      'resource_type': instance.resourceType,
      'resource_id': instance.resourceId,
      'meta_data': instance.metaData,
      'reason': instance.reason,
      'ip_address': instance.ipAddress,
      'user_agent': instance.userAgent,
      'created_at': instance.createdAt?.toIso8601String(),
    };
