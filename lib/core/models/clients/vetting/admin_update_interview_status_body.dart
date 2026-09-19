import 'package:json_annotation/json_annotation.dart';

part 'admin_update_interview_status_body.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: true)
class AdminUpdateInterviewStatusBody {
  final String status;
  final String? notes;
  final String? meetingLink;
  final String? scheduledAt;

  const AdminUpdateInterviewStatusBody({
    required this.status,
    this.notes,
    this.meetingLink,
    this.scheduledAt,
  });

  factory AdminUpdateInterviewStatusBody.fromJson(Map<String, dynamic> json) =>
      _$AdminUpdateInterviewStatusBodyFromJson(json);

  Map<String, dynamic> toJson() => _$AdminUpdateInterviewStatusBodyToJson(this);
}
