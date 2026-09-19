import 'package:json_annotation/json_annotation.dart';

part 'admin_add_support_internal_note_body.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminAddSupportInternalNoteBody {
  final String body;

  const AdminAddSupportInternalNoteBody({
    required this.body,
  });

  factory AdminAddSupportInternalNoteBody.fromJson(Map<String, dynamic> json) =>
      _$AdminAddSupportInternalNoteBodyFromJson(json);

  Map<String, dynamic> toJson() => _$AdminAddSupportInternalNoteBodyToJson(this);
}
