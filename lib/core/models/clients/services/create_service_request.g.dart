// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_service_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateServiceRequest _$CreateServiceRequestFromJson(
  Map<String, dynamic> json,
) => CreateServiceRequest(
  name: json['name'] as String,
  categoryId: json['category_id'] as String?,
  imageUrl: json['image_url'] as String?,
  basePrice: json['base_price'] as num? ?? 0,
  defaultDurationMin: (json['default_duration_min'] as num?)?.toInt() ?? 60,
  perKmRate: json['per_km_rate'] as num? ?? 150,
  perMinuteRate: json['per_minute_rate'] as num? ?? 20,
  takeRate: json['take_rate'] as num? ?? 0.15,
  minTierRequired: (json['min_tier_required'] as num?)?.toInt() ?? 4,
  isHighRisk: json['is_high_risk'] as bool? ?? false,
  isActive: json['is_active'] as bool? ?? true,
);

Map<String, dynamic> _$CreateServiceRequestToJson(
  CreateServiceRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'category_id': ?instance.categoryId,
  'image_url': ?instance.imageUrl,
  'base_price': ?instance.basePrice,
  'default_duration_min': ?instance.defaultDurationMin,
  'per_km_rate': ?instance.perKmRate,
  'per_minute_rate': ?instance.perMinuteRate,
  'take_rate': ?instance.takeRate,
  'min_tier_required': ?instance.minTierRequired,
  'is_high_risk': ?instance.isHighRisk,
  'is_active': ?instance.isActive,
};
