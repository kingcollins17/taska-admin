import 'package:json_annotation/json_annotation.dart';

part 'admin_dispatch_attempt_provider.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminDispatchAttemptProvider {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;

  const AdminDispatchAttemptProvider({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
  });

  factory AdminDispatchAttemptProvider.fromJson(Map<String, dynamic> json) =>
      _$AdminDispatchAttemptProviderFromJson(json);

  Map<String, dynamic> toJson() => _$AdminDispatchAttemptProviderToJson(this);
}
