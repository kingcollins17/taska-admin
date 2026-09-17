// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_task_attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminTaskAttachment _$AdminTaskAttachmentFromJson(Map<String, dynamic> json) =>
    AdminTaskAttachment(
      id: json['id'] as String?,
      taskId: json['task_id'] as String?,
      storageKey: json['storage_key'] as String?,
      fileName: json['file_name'] as String?,
      fileSize: (json['file_size'] as num?)?.toInt(),
      mimeType: json['mime_type'] as String?,
      url: json['url'] as String?,
      type: json['type'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AdminTaskAttachmentToJson(
  AdminTaskAttachment instance,
) => <String, dynamic>{
  'id': instance.id,
  'task_id': instance.taskId,
  'storage_key': instance.storageKey,
  'file_name': instance.fileName,
  'file_size': instance.fileSize,
  'mime_type': instance.mimeType,
  'url': instance.url,
  'type': instance.type,
  'created_at': instance.createdAt?.toIso8601String(),
};
