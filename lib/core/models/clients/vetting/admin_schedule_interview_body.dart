import 'package:json_annotation/json_annotation.dart';

part 'admin_schedule_interview_body.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminScheduleInterviewBody {
  final String userId;
  final String scheduledAt;
  final String? meetingLink;
  final String? notes;

  const AdminScheduleInterviewBody({
    required this.userId,
    required this.scheduledAt,
    this.meetingLink,
    this.notes,
  });

  factory AdminScheduleInterviewBody.fromJson(Map<String, dynamic> json) =>
      _$AdminScheduleInterviewBodyFromJson(json);

  Map<String, dynamic> toJson() => _$AdminScheduleInterviewBodyToJson(this);
}
