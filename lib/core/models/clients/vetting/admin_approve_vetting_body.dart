import 'package:json_annotation/json_annotation.dart';

part 'admin_approve_vetting_body.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminApproveVettingBody {
  final String? notes;

  const AdminApproveVettingBody({
    this.notes,
  });

  factory AdminApproveVettingBody.fromJson(Map<String, dynamic> json) =>
      _$AdminApproveVettingBodyFromJson(json);

  Map<String, dynamic> toJson() => _$AdminApproveVettingBodyToJson(this);
}
