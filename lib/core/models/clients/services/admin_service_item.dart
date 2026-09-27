import 'package:json_annotation/json_annotation.dart';
import 'admin_category_item.dart';

part 'admin_service_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminServiceItem {
  final String? id;
  final String? name;
  final String? imageUrl;
  final num? basePrice;
  final int? defaultDurationMin;
  final num? perKmRate;
  final num? perMinuteRate;
  final num? takeRate;
  final int? minTierRequired;
  final bool? isHighRisk;
  final bool? isActive;
  final String? categoryId;
  final AdminCategoryItem? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminServiceItem({
    this.id,
    this.name,
    this.imageUrl,
    this.basePrice,
    this.defaultDurationMin,
    this.perKmRate,
    this.perMinuteRate,
    this.takeRate,
    this.minTierRequired,
    this.isHighRisk,
    this.isActive,
    this.categoryId,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminServiceItem.fromJson(Map<String, dynamic> json) =>
      _$AdminServiceItemFromJson(json);

  Map<String, dynamic> toJson() => _$AdminServiceItemToJson(this);
}
