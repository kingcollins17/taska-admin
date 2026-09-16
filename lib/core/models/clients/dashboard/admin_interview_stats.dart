import 'package:json_annotation/json_annotation.dart';

part 'admin_interview_stats.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminInterviewStats {
  final int? totalInterviews;
  final int? totalScheduled;
  final int? totalPassed;
  final int? totalFailed;
  final int? totalCancelled;
  final int? totalRescheduled;

  const AdminInterviewStats({
    this.totalInterviews,
    this.totalScheduled,
    this.totalPassed,
    this.totalFailed,
    this.totalCancelled,
    this.totalRescheduled,
  });

  factory AdminInterviewStats.fromJson(Map<String, dynamic> json) =>
      _$AdminInterviewStatsFromJson(json);

  Map<String, dynamic> toJson() => _$AdminInterviewStatsToJson(this);
}
