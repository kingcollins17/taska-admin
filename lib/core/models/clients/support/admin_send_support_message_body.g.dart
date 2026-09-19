// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_send_support_message_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminSendSupportMessageBody _$AdminSendSupportMessageBodyFromJson(
  Map<String, dynamic> json,
) => AdminSendSupportMessageBody(
  body: json['body'] as String,
  channel: json['channel'] as String? ?? 'IN_APP',
  visibility: json['visibility'] as String? ?? 'PUBLIC',
  statusUpdate: json['status_update'] as String?,
  attachmentIds: (json['attachment_ids'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$AdminSendSupportMessageBodyToJson(
  AdminSendSupportMessageBody instance,
) => <String, dynamic>{
  'body': instance.body,
  'channel': instance.channel,
  'visibility': instance.visibility,
  'status_update': instance.statusUpdate,
  'attachment_ids': instance.attachmentIds,
};
