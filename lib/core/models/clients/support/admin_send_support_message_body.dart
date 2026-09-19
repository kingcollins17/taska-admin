import 'package:json_annotation/json_annotation.dart';

part 'admin_send_support_message_body.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminSendSupportMessageBody {
  final String body;
  final String? channel;
  final String? visibility;
  final String? statusUpdate;
  final List<String>? attachmentIds;

  const AdminSendSupportMessageBody({
    required this.body,
    this.channel = 'IN_APP',
    this.visibility = 'PUBLIC',
    this.statusUpdate,
    this.attachmentIds,
  });

  factory AdminSendSupportMessageBody.fromJson(Map<String, dynamic> json) =>
      _$AdminSendSupportMessageBodyFromJson(json);

  Map<String, dynamic> toJson() => _$AdminSendSupportMessageBodyToJson(this);
}
