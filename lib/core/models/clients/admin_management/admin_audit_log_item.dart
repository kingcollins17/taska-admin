import 'package:json_annotation/json_annotation.dart';

part 'admin_audit_log_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminAuditLogItem {
  final String? id;
  final String? adminId;
  final String? action;
  final String? resourceType;
  final String? resourceId;
  final Map<String, dynamic>? metaData;
  final String? reason;
  final String? ipAddress;
  final String? userAgent;
  final DateTime? createdAt;

  const AdminAuditLogItem({
    this.id,
    this.adminId,
    this.action,
    this.resourceType,
    this.resourceId,
    this.metaData,
    this.reason,
    this.ipAddress,
    this.userAgent,
    this.createdAt,
  });

  factory AdminAuditLogItem.fromJson(Map<String, dynamic> json) =>
      _$AdminAuditLogItemFromJson(json);

  Map<String, dynamic> toJson() => _$AdminAuditLogItemToJson(this);
}
