import 'package:json_annotation/json_annotation.dart';

part 'admin_support_timeline_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminSupportTimelineItem {
  final String? id;
  final String? itemType;
  final String? timestamp;
  final String? title;
  final String? description;
  final String? actorType;
  final String? actorId;
  final Map<String, dynamic>? metadata;

  const AdminSupportTimelineItem({
    this.id,
    this.itemType,
    this.timestamp,
    this.title,
    this.description,
    this.actorType,
    this.actorId,
    this.metadata,
  });

  factory AdminSupportTimelineItem.fromJson(Map<String, dynamic> json) =>
      _$AdminSupportTimelineItemFromJson(json);

  Map<String, dynamic> toJson() => _$AdminSupportTimelineItemToJson(this);
}
