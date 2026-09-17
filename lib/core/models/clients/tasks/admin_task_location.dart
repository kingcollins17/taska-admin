import 'package:json_annotation/json_annotation.dart';

part 'admin_task_location.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminTaskLocation {
  final String? id;
  final String? taskId;
  final String? locationType;
  final num? latitude;
  final num? longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final num? distanceKm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminTaskLocation({
    this.id,
    this.taskId,
    this.locationType,
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.state,
    this.country,
    this.distanceKm,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminTaskLocation.fromJson(Map<String, dynamic> json) =>
      _$AdminTaskLocationFromJson(json);

  Map<String, dynamic> toJson() => _$AdminTaskLocationToJson(this);
}
