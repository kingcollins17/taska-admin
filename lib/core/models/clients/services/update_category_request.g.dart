// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_category_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCategoryRequest _$UpdateCategoryRequestFromJson(
  Map<String, dynamic> json,
) => UpdateCategoryRequest(
  name: json['name'] as String?,
  description: json['description'] as String?,
  imageUrl: json['image_url'] as String?,
  defaultBasePrice: json['default_base_price'] as num?,
  defaultDurationMin: (json['default_duration_min'] as num?)?.toInt(),
  perKmRate: json['per_km_rate'] as num?,
  perMinuteRate: json['per_minute_rate'] as num?,
  isActive: json['is_active'] as bool?,
);

Map<String, dynamic> _$UpdateCategoryRequestToJson(
  UpdateCategoryRequest instance,
) => <String, dynamic>{
  'name': ?instance.name,
  'description': ?instance.description,
  'image_url': ?instance.imageUrl,
  'default_base_price': ?instance.defaultBasePrice,
  'default_duration_min': ?instance.defaultDurationMin,
  'per_km_rate': ?instance.perKmRate,
  'per_minute_rate': ?instance.perMinuteRate,
  'is_active': ?instance.isActive,
};
