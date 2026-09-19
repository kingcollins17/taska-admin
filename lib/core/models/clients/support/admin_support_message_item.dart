import 'package:json_annotation/json_annotation.dart';

part 'admin_support_message_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminSupportMessageItem {
  final String? id;
  final String? caseId;
  final String? senderType;
  final String? senderId;
  final String? channel;
  final String? visibility;
  final String? body;
  final String? emailMessageId;
  final String? createdAt;

  const AdminSupportMessageItem({
    this.id,
    this.caseId,
    this.senderType,
    this.senderId,
    this.channel,
    this.visibility,
    this.body,
    this.emailMessageId,
    this.createdAt,
  });

  factory AdminSupportMessageItem.fromJson(Map<String, dynamic> json) =>
      _$AdminSupportMessageItemFromJson(json);

  Map<String, dynamic> toJson() => _$AdminSupportMessageItemToJson(this);
}
