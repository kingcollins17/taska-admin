import 'package:json_annotation/json_annotation.dart';

part 'admin_platform_user_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminPlatformUserItem {
  final String? id;
  final String? email;
  final String? phoneNumber;
  final String? fullname;
  final String? type;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;
  final String? regionId;

  const AdminPlatformUserItem({
    this.id,
    this.email,
    this.phoneNumber,
    this.fullname,
    this.type,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.regionId,
  });

  factory AdminPlatformUserItem.fromJson(Map<String, dynamic> json) =>
      _$AdminPlatformUserItemFromJson(json);

  Map<String, dynamic> toJson() => _$AdminPlatformUserItemToJson(this);
}
