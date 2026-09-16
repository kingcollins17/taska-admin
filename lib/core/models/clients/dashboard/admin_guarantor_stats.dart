import 'package:json_annotation/json_annotation.dart';

part 'admin_guarantor_stats.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminGuarantorStats {
  final int? totalGuarantors;
  final int? totalPassed;
  final int? totalFailed;
  final int? totalPending;
  final int? totalUnderReview;

  const AdminGuarantorStats({
    this.totalGuarantors,
    this.totalPassed,
    this.totalFailed,
    this.totalPending,
    this.totalUnderReview,
  });

  factory AdminGuarantorStats.fromJson(Map<String, dynamic> json) =>
      _$AdminGuarantorStatsFromJson(json);

  Map<String, dynamic> toJson() => _$AdminGuarantorStatsToJson(this);
}
