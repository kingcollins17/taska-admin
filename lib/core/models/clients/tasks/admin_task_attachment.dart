import 'package:json_annotation/json_annotation.dart';

part 'admin_task_attachment.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminTaskAttachment {
  final String? id;
  final String? taskId;
  final String? storageKey;
  final String? fileName;
  final int? fileSize;
  final String? mimeType;
  final String? url;
  final String? type;
  final DateTime? createdAt;

  const AdminTaskAttachment({
    this.id,
    this.taskId,
    this.storageKey,
    this.fileName,
    this.fileSize,
    this.mimeType,
    this.url,
    this.type,
    this.createdAt,
  });

  factory AdminTaskAttachment.fromJson(Map<String, dynamic> json) =>
      _$AdminTaskAttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$AdminTaskAttachmentToJson(this);
}
