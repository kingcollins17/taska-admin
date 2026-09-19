// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_support_timeline_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminSupportTimelineItem _$AdminSupportTimelineItemFromJson(
  Map<String, dynamic> json,
) => AdminSupportTimelineItem(
  id: json['id'] as String?,
  itemType: json['item_type'] as String?,
  timestamp: json['timestamp'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  actorType: json['actor_type'] as String?,
  actorId: json['actor_id'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$AdminSupportTimelineItemToJson(
  AdminSupportTimelineItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'item_type': instance.itemType,
  'timestamp': instance.timestamp,
  'title': instance.title,
  'description': instance.description,
  'actor_type': instance.actorType,
  'actor_id': instance.actorId,
  'metadata': instance.metadata,
};
