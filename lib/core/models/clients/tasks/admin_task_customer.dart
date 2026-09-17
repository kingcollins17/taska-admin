import 'package:json_annotation/json_annotation.dart';

part 'admin_task_customer.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminTaskCustomer {
  final String? id;
  final String? fullname;
  final String? email;
  final String? phoneNumber;
  final num? averageRatings;
  final num? credibilityScore;
  final String? gender;

  const AdminTaskCustomer({
    this.id,
    this.fullname,
    this.email,
    this.phoneNumber,
    this.averageRatings,
    this.credibilityScore,
    this.gender,
  });

  factory AdminTaskCustomer.fromJson(Map<String, dynamic> json) =>
      _$AdminTaskCustomerFromJson(json);

  Map<String, dynamic> toJson() => _$AdminTaskCustomerToJson(this);
}
