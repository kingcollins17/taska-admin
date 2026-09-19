// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_support_case_initiator.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminSupportCaseInitiator _$AdminSupportCaseInitiatorFromJson(
  Map<String, dynamic> json,
) => AdminSupportCaseInitiator(
  id: json['id'] as String?,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phone_number'] as String?,
);

Map<String, dynamic> _$AdminSupportCaseInitiatorToJson(
  AdminSupportCaseInitiator instance,
) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'email': instance.email,
  'phone_number': instance.phoneNumber,
};
