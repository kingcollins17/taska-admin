import 'package:json_annotation/json_annotation.dart';

import 'admin_region.dart';

part 'admin_user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminUser {
  final String? id;
  final String? email;
  final String? fullname;
  final String? role;
  final String? parentAdminId;
  final String? createdById;
  final String? regionId;
  final AdminRegion? region;
  final bool? isActive;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminUser({
    this.id,
    this.email,
    this.fullname,
    this.role,
    this.parentAdminId,
    this.createdById,
    this.regionId,
    this.region,
    this.isActive,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) =>
      _$AdminUserFromJson(json);

  Map<String, dynamic> toJson() => _$AdminUserToJson(this);
}
