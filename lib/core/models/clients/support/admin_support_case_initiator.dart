import 'package:json_annotation/json_annotation.dart';

part 'admin_support_case_initiator.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminSupportCaseInitiator {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;

  const AdminSupportCaseInitiator({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
  });

  factory AdminSupportCaseInitiator.fromJson(Map<String, dynamic> json) =>
      _$AdminSupportCaseInitiatorFromJson(json);

  Map<String, dynamic> toJson() => _$AdminSupportCaseInitiatorToJson(this);
}
