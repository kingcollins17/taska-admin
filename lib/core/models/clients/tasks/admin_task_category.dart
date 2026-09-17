import 'package:json_annotation/json_annotation.dart';

part 'admin_task_category.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminTaskCategory {
  final String? id;
  final String? name;
  final String? description;
  final String? imageUrl;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminTaskCategory({
    this.id,
    this.name,
    this.description,
    this.imageUrl,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminTaskCategory.fromJson(Map<String, dynamic> json) =>
      _$AdminTaskCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$AdminTaskCategoryToJson(this);
}
