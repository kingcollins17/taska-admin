import 'package:json_annotation/json_annotation.dart';

part 'admin_support_attachment_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminSupportAttachmentItem {
  final String? id;
  final String? caseId;
  final String? messageId;
  final String? uploadedBy;
  final String? storageKey;
  final String? filename;
  final String? mimeType;
  final num? size;
  final String? createdAt;

  const AdminSupportAttachmentItem({
    this.id,
    this.caseId,
    this.messageId,
    this.uploadedBy,
    this.storageKey,
    this.filename,
    this.mimeType,
    this.size,
    this.createdAt,
  });

  factory AdminSupportAttachmentItem.fromJson(Map<String, dynamic> json) =>
      _$AdminSupportAttachmentItemFromJson(json);

  Map<String, dynamic> toJson() => _$AdminSupportAttachmentItemToJson(this);
}
