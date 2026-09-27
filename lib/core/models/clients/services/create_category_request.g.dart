// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_category_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCategoryRequest _$CreateCategoryRequestFromJson(
  Map<String, dynamic> json,
) => CreateCategoryRequest(
  name: json['name'] as String,
  description: json['description'] as String?,
  imageUrl: json['image_url'] as String?,
  defaultBasePrice: json['default_base_price'] as num? ?? 0,
  defaultDurationMin: (json['default_duration_min'] as num?)?.toInt() ?? 60,
  perKmRate: json['per_km_rate'] as num? ?? 150,
  perMinuteRate: json['per_minute_rate'] as num? ?? 20,
  isActive: json['is_active'] as bool? ?? true,
);

Map<String, dynamic> _$CreateCategoryRequestToJson(
  CreateCategoryRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': ?instance.description,
  'image_url': ?instance.imageUrl,
  'default_base_price': ?instance.defaultBasePrice,
  'default_duration_min': ?instance.defaultDurationMin,
  'per_km_rate': ?instance.perKmRate,
  'per_minute_rate': ?instance.perMinuteRate,
  'is_active': ?instance.isActive,
};
