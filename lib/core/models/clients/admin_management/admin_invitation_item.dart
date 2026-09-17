import 'package:json_annotation/json_annotation.dart';

part 'admin_invitation_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminInvitationItem {
  final String? id;
  final String? email;
  final String? role;
  final String? invitedById;
  final String? status;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  const AdminInvitationItem({
    this.id,
    this.email,
    this.role,
    this.invitedById,
    this.status,
    this.expiresAt,
    this.createdAt,
  });

  factory AdminInvitationItem.fromJson(Map<String, dynamic> json) =>
      _$AdminInvitationItemFromJson(json);

  Map<String, dynamic> toJson() => _$AdminInvitationItemToJson(this);
}
