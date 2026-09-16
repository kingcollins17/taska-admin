import 'package:json_annotation/json_annotation.dart';

part 'admin_kyc_stats.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminKycStats {
  final int? totalDocuments;
  final int? totalVerified;
  final int? totalRejected;
  final int? totalPending;
  final int? totalSubmitted;
  final int? totalUnderReview;

  const AdminKycStats({
    this.totalDocuments,
    this.totalVerified,
    this.totalRejected,
    this.totalPending,
    this.totalSubmitted,
    this.totalUnderReview,
  });

  factory AdminKycStats.fromJson(Map<String, dynamic> json) =>
      _$AdminKycStatsFromJson(json);

  Map<String, dynamic> toJson() => _$AdminKycStatsToJson(this);
}
