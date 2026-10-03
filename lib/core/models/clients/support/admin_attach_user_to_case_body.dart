import 'package:json_annotation/json_annotation.dart';

part 'admin_attach_user_to_case_body.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminAttachUserToCaseBody {
  final String userId;

  const AdminAttachUserToCaseBody({
    required this.userId,
  });

  factory AdminAttachUserToCaseBody.fromJson(Map<String, dynamic> json) =>
      _$AdminAttachUserToCaseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$AdminAttachUserToCaseBodyToJson(this);
}
