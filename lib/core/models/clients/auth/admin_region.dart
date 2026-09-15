import 'package:json_annotation/json_annotation.dart';

part 'admin_region.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminRegion {
  final String? id;
  final String? addressLine;
  final String? state;
  final bool? isActive;
  final int? totalProviders;
  final int? totalCustomers;
  final int? totalTasks;
  final int? totalStaff;
  final String? location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminRegion({
    this.id,
    this.addressLine,
    this.state,
    this.isActive,
    this.totalProviders,
    this.totalCustomers,
    this.totalTasks,
    this.totalStaff,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminRegion.fromJson(Map<String, dynamic> json) =>
      _$AdminRegionFromJson(json);

  Map<String, dynamic> toJson() => _$AdminRegionToJson(this);
}
