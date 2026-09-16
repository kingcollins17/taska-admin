import 'package:json_annotation/json_annotation.dart';

part 'admin_interview_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminInterviewItem {
  final String? id;
  final String? userId;
  final String? adminId;
  final String? scheduledAt;
  final String? meetingLink;
  final String? status;
  final String? notes;
  final String? passedAt;
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic>? metaData;

  const AdminInterviewItem({
    this.id,
    this.userId,
    this.adminId,
    this.scheduledAt,
    this.meetingLink,
    this.status,
    this.notes,
    this.passedAt,
    this.createdAt,
    this.updatedAt,
    this.metaData,
  });

  factory AdminInterviewItem.fromJson(Map<String, dynamic> json) =>
      _$AdminInterviewItemFromJson(json);

  Map<String, dynamic> toJson() => _$AdminInterviewItemToJson(this);
}
