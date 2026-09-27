import 'package:json_annotation/json_annotation.dart';

part 'create_service_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class CreateServiceRequest {
  final String name;
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

  const CreateServiceRequest({
    required this.name,
    this.categoryId,
    this.imageUrl,
    this.basePrice = 0,
    this.defaultDurationMin = 60,
    this.perKmRate = 150,
    this.perMinuteRate = 20,
    this.takeRate = 0.15,
    this.minTierRequired = 4,
    this.isHighRisk = false,
    this.isActive = true,
  });

  factory CreateServiceRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateServiceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateServiceRequestToJson(this);
}
