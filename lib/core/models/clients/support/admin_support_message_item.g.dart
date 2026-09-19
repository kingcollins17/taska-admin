// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_support_message_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminSupportMessageItem _$AdminSupportMessageItemFromJson(
  Map<String, dynamic> json,
) => AdminSupportMessageItem(
  id: json['id'] as String?,
  caseId: json['case_id'] as String?,
  senderType: json['sender_type'] as String?,
  senderId: json['sender_id'] as String?,
  channel: json['channel'] as String?,
  visibility: json['visibility'] as String?,
  body: json['body'] as String?,
  emailMessageId: json['email_message_id'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$AdminSupportMessageItemToJson(
  AdminSupportMessageItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'case_id': instance.caseId,
  'sender_type': instance.senderType,
  'sender_id': instance.senderId,
  'channel': instance.channel,
  'visibility': instance.visibility,
  'body': instance.body,
  'email_message_id': instance.emailMessageId,
  'created_at': instance.createdAt,
};
