// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_task_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminTaskCategory _$AdminTaskCategoryFromJson(Map<String, dynamic> json) =>
    AdminTaskCategory(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$AdminTaskCategoryToJson(AdminTaskCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'image_url': instance.imageUrl,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
