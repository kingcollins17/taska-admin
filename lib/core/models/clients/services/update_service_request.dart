import 'package:json_annotation/json_annotation.dart';

part 'update_service_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class UpdateServiceRequest {
  final String? name;
  final String? categoryId;
  final String? imageUrl;
  final num? basePrice;
  final int? defaultDurationMin;
  final num? perKmRate;
  final num? perMinuteRate;
  final num? takeRate;
  final int? minTierRequired;
  final bool? isHighRisk;
  final bool? isActive;

  const UpdateServiceRequest({
    this.name,
    this.categoryId,
    this.imageUrl,
    this.basePrice,
    this.defaultDurationMin,
    this.perKmRate,
    this.perMinuteRate,
    this.takeRate,
    this.minTierRequired,
    this.isHighRisk,
    this.isActive,
  });

  factory UpdateServiceRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateServiceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateServiceRequestToJson(this);
}
