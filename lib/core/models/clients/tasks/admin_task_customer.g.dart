// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_task_customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminTaskCustomer _$AdminTaskCustomerFromJson(Map<String, dynamic> json) =>
    AdminTaskCustomer(
      id: json['id'] as String?,
      fullname: json['fullname'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      averageRatings: json['average_ratings'] as num?,
      credibilityScore: json['credibility_score'] as num?,
      gender: json['gender'] as String?,
    );

Map<String, dynamic> _$AdminTaskCustomerToJson(AdminTaskCustomer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullname': instance.fullname,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'average_ratings': instance.averageRatings,
      'credibility_score': instance.credibilityScore,
      'gender': instance.gender,
    };
