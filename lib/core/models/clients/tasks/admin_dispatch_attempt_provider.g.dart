// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dispatch_attempt_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminDispatchAttemptProvider _$AdminDispatchAttemptProviderFromJson(
  Map<String, dynamic> json,
) => AdminDispatchAttemptProvider(
  id: json['id'] as String?,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phone_number'] as String?,
);

Map<String, dynamic> _$AdminDispatchAttemptProviderToJson(
  AdminDispatchAttemptProvider instance,
) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'email': instance.email,
  'phone_number': instance.phoneNumber,
};
