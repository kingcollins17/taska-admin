import 'package:json_annotation/json_annotation.dart';

part 'admin_category_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminCategoryItem {
  final String? id;
  final String? name;
  final String? description;
  final String? imageUrl;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminCategoryItem({
    this.id,
    this.name,
    this.description,
    this.imageUrl,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminCategoryItem.fromJson(Map<String, dynamic> json) =>
      _$AdminCategoryItemFromJson(json);

  Map<String, dynamic> toJson() => _$AdminCategoryItemToJson(this);
}
