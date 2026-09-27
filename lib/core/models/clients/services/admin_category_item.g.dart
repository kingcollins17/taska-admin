// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_category_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminCategoryItem _$AdminCategoryItemFromJson(Map<String, dynamic> json) =>
    AdminCategoryItem(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      defaultBasePrice: json['default_base_price'] as num?,
      defaultDurationMin: (json['default_duration_min'] as num?)?.toInt(),
      perKmRate: json['per_km_rate'] as num?,
      perMinuteRate: json['per_minute_rate'] as num?,
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$AdminCategoryItemToJson(AdminCategoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'image_url': instance.imageUrl,
      'default_base_price': instance.defaultBasePrice,
      'default_duration_min': instance.defaultDurationMin,
      'per_km_rate': instance.perKmRate,
      'per_minute_rate': instance.perMinuteRate,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
