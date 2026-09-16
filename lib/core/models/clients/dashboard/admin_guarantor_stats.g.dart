// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_guarantor_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminGuarantorStats _$AdminGuarantorStatsFromJson(Map<String, dynamic> json) =>
    AdminGuarantorStats(
      totalGuarantors: (json['total_guarantors'] as num?)?.toInt(),
      totalPassed: (json['total_passed'] as num?)?.toInt(),
      totalFailed: (json['total_failed'] as num?)?.toInt(),
      totalPending: (json['total_pending'] as num?)?.toInt(),
      totalUnderReview: (json['total_under_review'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AdminGuarantorStatsToJson(
  AdminGuarantorStats instance,
) => <String, dynamic>{
  'total_guarantors': instance.totalGuarantors,
  'total_passed': instance.totalPassed,
  'total_failed': instance.totalFailed,
  'total_pending': instance.totalPending,
  'total_under_review': instance.totalUnderReview,
};
