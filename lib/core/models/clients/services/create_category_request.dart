import 'package:json_annotation/json_annotation.dart';

part 'create_category_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class CreateCategoryRequest {
  final String name;
  final String? description;
  final String? imageUrl;
  final num? defaultBasePrice;
  final int? defaultDurationMin;
  final num? perKmRate;
  final num? perMinuteRate;
  final bool? isActive;

  const CreateCategoryRequest({
    required this.name,
    this.description,
    this.imageUrl,
    this.defaultBasePrice = 0,
    this.defaultDurationMin = 60,
    this.perKmRate = 150,
    this.perMinuteRate = 20,
    this.isActive = true,
  });

  factory CreateCategoryRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCategoryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCategoryRequestToJson(this);
}
