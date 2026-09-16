import 'package:json_annotation/json_annotation.dart';

part 'admin_reject_vetting_body.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminRejectVettingBody {
  final String reason;
  final String? notes;

  const AdminRejectVettingBody({
    required this.reason,
    this.notes,
  });

  factory AdminRejectVettingBody.fromJson(Map<String, dynamic> json) =>
      _$AdminRejectVettingBodyFromJson(json);

  Map<String, dynamic> toJson() => _$AdminRejectVettingBodyToJson(this);
}
