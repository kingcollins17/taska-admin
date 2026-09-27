// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_service_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateServiceRequest _$UpdateServiceRequestFromJson(
  Map<String, dynamic> json,
) => UpdateServiceRequest(
  name: json['name'] as String?,
  categoryId: json['category_id'] as String?,
  imageUrl: json['image_url'] as String?,
  basePrice: json['base_price'] as num?,
  defaultDurationMin: (json['default_duration_min'] as num?)?.toInt(),
  perKmRate: json['per_km_rate'] as num?,
  perMinuteRate: json['per_minute_rate'] as num?,
  takeRate: json['take_rate'] as num?,
  minTierRequired: (json['min_tier_required'] as num?)?.toInt(),
  isHighRisk: json['is_high_risk'] as bool?,
  isActive: json['is_active'] as bool?,
);

Map<String, dynamic> _$UpdateServiceRequestToJson(
  UpdateServiceRequest instance,
) => <String, dynamic>{
  'name': ?instance.name,
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
