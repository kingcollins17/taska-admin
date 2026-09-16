import 'package:json_annotation/json_annotation.dart';

part 'admin_guarantor_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminGuarantorItem {
  final String? id;
  final String? providerId;
  final String? guarantorName;
  final String? guarantorPhone;
  final String? relationship;
  final String? status;
  final Map<String, dynamic>? metaData;
  final String? verifiedAt;
  final String? createdAt;

  const AdminGuarantorItem({
    this.id,
    this.providerId,
    this.guarantorName,
    this.guarantorPhone,
    this.relationship,
    this.status,
    this.metaData,
    this.verifiedAt,
    this.createdAt,
  });

  factory AdminGuarantorItem.fromJson(Map<String, dynamic> json) =>
      _$AdminGuarantorItemFromJson(json);

  Map<String, dynamic> toJson() => _$AdminGuarantorItemToJson(this);
}
