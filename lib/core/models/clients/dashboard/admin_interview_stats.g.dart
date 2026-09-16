// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_interview_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminInterviewStats _$AdminInterviewStatsFromJson(Map<String, dynamic> json) =>
    AdminInterviewStats(
      totalInterviews: (json['total_interviews'] as num?)?.toInt(),
      totalScheduled: (json['total_scheduled'] as num?)?.toInt(),
      totalPassed: (json['total_passed'] as num?)?.toInt(),
      totalFailed: (json['total_failed'] as num?)?.toInt(),
      totalCancelled: (json['total_cancelled'] as num?)?.toInt(),
      totalRescheduled: (json['total_rescheduled'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AdminInterviewStatsToJson(
  AdminInterviewStats instance,
) => <String, dynamic>{
  'total_interviews': instance.totalInterviews,
  'total_scheduled': instance.totalScheduled,
  'total_passed': instance.totalPassed,
  'total_failed': instance.totalFailed,
  'total_cancelled': instance.totalCancelled,
  'total_rescheduled': instance.totalRescheduled,
};
