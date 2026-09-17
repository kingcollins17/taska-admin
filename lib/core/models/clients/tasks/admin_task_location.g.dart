// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_task_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminTaskLocation _$AdminTaskLocationFromJson(Map<String, dynamic> json) =>
    AdminTaskLocation(
      id: json['id'] as String?,
      taskId: json['task_id'] as String?,
      locationType: json['location_type'] as String?,
      latitude: json['latitude'] as num?,
      longitude: json['longitude'] as num?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      distanceKm: json['distance_km'] as num?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$AdminTaskLocationToJson(AdminTaskLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'location_type': instance.locationType,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'distance_km': instance.distanceKm,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
