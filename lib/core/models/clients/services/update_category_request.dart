import 'package:json_annotation/json_annotation.dart';

part 'update_category_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class UpdateCategoryRequest {
  final String? name;
  final String? description;
  final String? imageUrl;
  final num? defaultBasePrice;
  final int? defaultDurationMin;
  final num? perKmRate;
  final num? perMinuteRate;
  final bool? isActive;

  const UpdateCategoryRequest({
    this.name,
    this.description,
    this.imageUrl,
    this.defaultBasePrice,
    this.defaultDurationMin,
    this.perKmRate,
    this.perMinuteRate,
    this.isActive,
  });

  factory UpdateCategoryRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCategoryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateCategoryRequestToJson(this);
}
