// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_kyc_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminKycStats _$AdminKycStatsFromJson(Map<String, dynamic> json) =>
    AdminKycStats(
      totalDocuments: (json['total_documents'] as num?)?.toInt(),
      totalVerified: (json['total_verified'] as num?)?.toInt(),
      totalRejected: (json['total_rejected'] as num?)?.toInt(),
      totalPending: (json['total_pending'] as num?)?.toInt(),
      totalSubmitted: (json['total_submitted'] as num?)?.toInt(),
      totalUnderReview: (json['total_under_review'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AdminKycStatsToJson(AdminKycStats instance) =>
    <String, dynamic>{
      'total_documents': instance.totalDocuments,
      'total_verified': instance.totalVerified,
      'total_rejected': instance.totalRejected,
      'total_pending': instance.totalPending,
      'total_submitted': instance.totalSubmitted,
      'total_under_review': instance.totalUnderReview,
    };
