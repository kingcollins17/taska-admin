import 'package:json_annotation/json_annotation.dart';

part 'admin_user_stats.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminUserStats {
  final int? totalUsers;
  final int? totalActive;
  final int? totalInactive;
  final int? totalCustomers;
  final int? totalProviders;

  const AdminUserStats({
    this.totalUsers,
    this.totalActive,
    this.totalInactive,
    this.totalCustomers,
    this.totalProviders,
  });

  factory AdminUserStats.fromJson(Map<String, dynamic> json) =>
      _$AdminUserStatsFromJson(json);

  Map<String, dynamic> toJson() => _$AdminUserStatsToJson(this);
}
